#define _GNU_SOURCE
#include <sched.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "HsFFI.h"

#ifdef __GLASGOW_HASKELL__
#include "Rts.h"
#endif

StgClosure Main_main_closure;

uint64_t gc_time[3] = {0,0,0};

void my_gc_hook(const struct GCDetails_ *stats) {
  if (stats->elapsed_ns < 1000000) {
     gc_time[0]++;
  } else if (stats->elapsed_ns < 10000000) {
     gc_time[0]++;
     gc_time[1]++;
  } else {
     gc_time[0]++;
     gc_time[1]++;
     gc_time[2]++;
  }
}

int main(int argc, char * argv[]) {
  int exit_status;
  SchedulerStatus status;
  #if __GLASGOW_HASKELL__ >= 703
  {
     RtsConfig conf = defaultRtsConfig;
     conf.gcDoneHook = my_gc_hook;
     conf.rts_opts_enabled = RtsOptsAll;
     hs_init_ghc(&argc, &argv, conf);
  }
  #else
     hs_init(&argc, &argv);
  #endif
  hs_init(&argc, &argv);
  {
     Capability *cap = rts_lock();
     rts_evalLazyIO(&cap, &Main_main_closure, NULL);
     status = rts_getSchedStatus(cap);
     rts_unlock(cap);
  }
  // check the status of the entire Haskell computation
 switch (status) {
    case Killed:
        errorBelch("main thread exited (uncaught exception)");
        exit_status = EXIT_KILLED;
        break;
    case Interrupted:
        errorBelch("interrupted");
        exit_status = EXIT_INTERRUPTED;
        break;
    case HeapExhausted:
        exit_status = EXIT_HEAPOVERFLOW;
        break;
    case Success:
        exit_status = EXIT_SUCCESS;
        break;
    default:
        barf("main thread completed with invalid status");
    }
  hs_exit();
  return 0;
}
