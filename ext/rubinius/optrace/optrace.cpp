#include <rbxti.hpp>
#include <rbxti/atomic.hpp>
#include <rbx_config.h>

#include <iostream>
#include <unordered_map>
#include <vector>
#include <map>

using namespace rbxti;

namespace optrace {

  typedef std::vector<std::pair<int,int> > InstructionList;
  typedef std::map<r_mint, rcompiled_code> CodeMap; 

  class Optrace {
    InstructionList inst_trace_;
    rbxti::SpinLock lock_;
    
    public:
    Optrace() { }

    void lock() {
      lock_.lock();
    }

    void unlock() {
      lock_.unlock();
    }

    void add(Env *env, r_mint id, int ip);
    robject results(Env *env);
  };

  void Optrace::add(Env *env, r_mint id, int ip) {
    lock();

    inst_trace_.push_back(std::make_pair(id, ip));

    unlock();
  }

  static void ccode_iterator(Env* env, rcompiled_code code, void* data) {
    CodeMap *map = (CodeMap *)data;
    r_mint id = env->method_id(code);
    (*map)[id] = code;
  }

  robject Optrace::results(Env *env) {
    CodeMap code_map;

    env->find_all_compiled_code(ccode_iterator, (void *)&code_map);

    rarray trace_array = env->array_new(inst_trace_.size());
    int trace_index = 0;
    for(InstructionList::iterator i = inst_trace_.begin(); i != inst_trace_.end(); ++i) {
      CodeMap::iterator j = code_map.find(i->first);
      if(j != code_map.end()) {
        rarray entry_array = env->array_new(2);
        env->array_set(entry_array, 0, env->integer_new(i->second));
        env->array_set(entry_array, 1, j->second);
        env->array_set(trace_array, trace_index++, entry_array); 
      }     
    }

    return trace_array;
  }
  
  namespace {
    void optrace_enable(Env* env) {
      Optrace* optrace = new Optrace;
      env->set_global_tool_data(optrace);
    }

    robject optrace_results(Env* env) {
      Optrace* optrace = reinterpret_cast<Optrace*>(env->global_tool_data());

      env->set_tool_at_ip(NULL);
      env->set_global_tool_data(NULL);

      robject results = optrace->results(env);
      delete optrace;

      return results;
    }

    void optrace_at_ip(Env* env, rmachine_code mcode, int ip) {
      Optrace* optrace = reinterpret_cast<Optrace*>(env->global_tool_data());

      if(!optrace) return;

      optrace->add(env, env->machine_code_id(mcode), ip);
    }
  }

  extern "C" int Tool_Init(Env* env) {
    env->set_tool_enable(optrace_enable);
    env->set_tool_results(optrace_results);

    env->set_tool_at_ip(optrace_at_ip);

    return 1;
  }
}
