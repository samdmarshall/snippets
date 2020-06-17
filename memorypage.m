#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
	@autoreleasepool {
		//			vm_size_t vmsize;
		//			vm_address_t address = (vm_address_t)imageHeader;
		//			vm_region_basic_info_data_t info;
		//			mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT;
		//			memory_object_name_t object;
		//			
		//			vm_region(mach_task_self_, &address, &vmsize, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &info_count, &object);
		//			
		//			printf("%s:\n\tMemory protection: %c%c%c  %c%c%c\n", name,
		//				   info.protection & VM_PROT_READ ? 'r' : '-',
		//				   info.protection & VM_PROT_WRITE ? 'w' : '-',
		//				   info.protection & VM_PROT_EXECUTE ? 'x' : '-',
		//				   
		//				   info.max_protection & VM_PROT_READ ? 'r' : '-',
		//				   info.max_protection & VM_PROT_WRITE ? 'w' : '-',
		//				   info.max_protection & VM_PROT_EXECUTE ? 'x' : '-'
		//				   );
	}
}