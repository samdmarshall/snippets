#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#include <assert.h>
#include <CoreServices/CoreServices.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <unistd.h>

typedef void* (*functionpointer)(NSMutableArray *array);

void* whileloop(NSMutableArray *array) {
	while (array.count) {
	        [array removeLastObject];
	    }
}

void* selector(NSMutableArray *array) {
	[array removeAllObjects];
}

uint64_t calculateremoval(functionpointer call, NSMutableArray *array)
{
    uint64_t        start;
    uint64_t        end;
    uint64_t        elapsed;
    uint64_t        elapsedNano;
    static mach_timebase_info_data_t    sTimebaseInfo;

    // Start the clock.

    start = mach_absolute_time();

    // Call getpid. This will produce inaccurate results because 
    // we're only making a single system call. For more accurate 
    // results you should call getpid multiple times and average 
    // the results.

    call(array);

    // Stop the clock.

    end = mach_absolute_time();

    // Calculate the duration.

    elapsed = end - start;

    // Convert to nanoseconds.

    // If this is the first time we've run, get the timebase.
    // We can use denom == 0 to indicate that sTimebaseInfo is 
    // uninitialised because it makes no sense to have a zero 
    // denominator is a fraction.

    if ( sTimebaseInfo.denom == 0 ) {
        (void) mach_timebase_info(&sTimebaseInfo);
    }

    // Do the maths. We hope that the multiplication doesn't 
    // overflow; the price you pay for working in fixed point.

    elapsedNano = elapsed * sTimebaseInfo.numer / sTimebaseInfo.denom;

    return elapsedNano;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		NSMutableArray *a = //[NSMutableArray new];
									CFBridgingRelease(CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks));
		NSMutableArray *b = //[NSMutableArray new];
									CFBridgingRelease(CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks));
		for (uint32_t i = 0; i < 10000000; i++) {
			NSString *a_string = [NSString stringWithFormat:@"%i",i];
			[a addObject:a_string];
			NSString *b_string = [NSString stringWithFormat:@"%i",i];
			[b addObject:b_string];
		}
		NSLog(@"starting");
		NSLog(@"%lli time\n",calculateremoval(whileloop, a));
		NSLog(@"%lli time\n",calculateremoval(selector, b));
		
		
	}
}