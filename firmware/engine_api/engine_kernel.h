#ifndef __ENGINE_KERNEL_H
#define __ENGINE_KERNEL_H

typedef void(*emit_ptr)(uint32_t);

typedef void(*kernel_ptr)(void(*)(uint32_t));

#define KERNEL(name) void name(emit_ptr emit)

KernelHandle load_kernel(kernel_ptr kernel, StreamingMultiprocessor preferred_sm);

KernelHandle load_kernel_at(kernel_ptr kernel, uint32_t addr);

#endif /* __ENGINE_KERNEL_H */
