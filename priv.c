
#include <sys/types.h>
#include <sys/ptrace.h>
#include <Security/Authorization.h>
#include <security/mac.h>
#include <mach-o/dyld.h>
#include <notify.h>

#import <mach/std_types.h>
#import <mach/mach_traps.h>
#import <signal.h>
#import <mach/mach_init.h>
#import <mach/vm_map.h>
#import <mach/mach_vm.h>
#import <mach/mach.h>

int acquireTaskportRight() {
	AuthorizationRef authorization;
	OSStatus status = AuthorizationCreate (NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorization);
	if (status != 0) {
		fprintf(stderr, "Error creating authorization reference\n");
		return -1;
	}
	AuthorizationItem right = { "system.privilege.taskport", 0, 0 , 0 };
	AuthorizationItem items[] = { right };
	AuthorizationRights rights = { sizeof(items) / sizeof(items[0]), items };
	AuthorizationFlags flags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights | kAuthorizationFlagPreAuthorize;
	
	status = AuthorizationCopyRights (authorization, &rights, kAuthorizationEmptyEnvironment, flags, NULL);
	if (status != 0) {
		fprintf(stderr, "Error authorizing current process with right to call task_for_pid\n");
		return -1;
	}
	return 0;
}


void checkStatus(int cond, char* msg) {
	if (!cond) {
		printf("%s\n", msg);
		exit(-1);
	}
}

void testingTaskForPid() {
	pid_t child = fork();
	
	if (child == 0) {
		/* PT_TRACE_ME will stop the process after the execl is executed and allows the parent
		 to take control. */
		checkStatus(!ptrace(PT_TRACE_ME, 0, 0, 0), "PT_TRACE_ME failed.");
		execl("/Applications/Calculator.app/Contents/MacOS/Calculator", "/Applications/Calculator.app/Contents/MacOS/Calculator", NULL);
	} else {
		/* Get the task for this pid. Seems to require superuser privileges or some gid hack.
		 Go Apple! */
		mach_port_t task;
		
		checkStatus(acquireTaskportRight()==0,"acquireTaskportRight failed");
		
		checkStatus(task_for_pid(mach_task_self(), child, &task) == KERN_SUCCESS, "task_for_pid failed.");
		
		/* Get the list of threads in that process (we expect one thread exactly.) */
		thread_act_port_array_t threadList;
		mach_msg_type_number_t threadCount;
		checkStatus(task_threads(task, &threadList, &threadCount) == KERN_SUCCESS, "task_threads failed.");
		checkStatus(threadCount == 1, "task has more than one thread.");
		
		
		/* Wait for updates from the child process we are tracing */
		int status;
		pid_t w = wait(&status);
		printf("wait pid: %d\n",w);
		
		
		/* Read the register state of the child via Mach (since we are single-stepping the child is guaranteed to be suspended at the moment. */
		x86_thread_state64_t state;
		mach_msg_type_number_t stateCount = x86_THREAD_STATE64_COUNT;
		checkStatus(thread_get_state(threadList[0],
							   x86_THREAD_STATE64,
							   (thread_state_t)&state,
							   &stateCount) == KERN_SUCCESS, "thread_get_state failed.");
		
		printf("RIP: %llx\n",state.__rip);
		
		
		
		
		checkStatus(ptrace(PT_CONTINUE, child, (char*)1, 0) == 0, "PT_CONTINUE failed.");
    }
}
