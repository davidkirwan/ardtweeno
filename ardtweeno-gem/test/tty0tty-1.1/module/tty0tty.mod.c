#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0xa71fca74, "module_layout" },
	{ 0x37a0cba, "kfree" },
	{ 0xa6a18b92, "tty_unregister_driver" },
	{ 0x87cfe6d5, "tty_unregister_device" },
	{ 0x55c6db81, "put_tty_driver" },
	{ 0xeb444686, "tty_register_driver" },
	{ 0x2efa8282, "tty_set_operations" },
	{ 0x67b27ec1, "tty_std_termios" },
	{ 0xcc5d0440, "__alloc_tty_driver" },
	{ 0x68dfc59f, "__init_waitqueue_head" },
	{ 0x3ff56293, "kmem_cache_alloc_trace" },
	{ 0x6579fb5b, "kmalloc_caches" },
	{ 0xa9c54d96, "tty_flip_buffer_push" },
	{ 0x55e1a9d5, "tty_insert_flip_string_fixed_flag" },
	{ 0x3a013b7d, "remove_wait_queue" },
	{ 0x4292364c, "schedule" },
	{ 0xd7bd3af2, "add_wait_queue" },
	{ 0xffd5a395, "default_wake_function" },
	{ 0x664846a3, "current_task" },
	{ 0x2f287f0d, "copy_to_user" },
	{ 0x126b8d26, "tty_get_baud_rate" },
	{ 0xc4554217, "up" },
	{ 0xdd1a2871, "down" },
	{ 0x50eedeb8, "printk" },
	{ 0xb4390f9a, "mcount" },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

