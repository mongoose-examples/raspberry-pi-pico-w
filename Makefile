PROG = firmware
WIFI_SSID="my_wifi"
WIFI_PASSWORD="my_password"

PROJECT_ROOT_PATH = $(realpath $(CURDIR))
DOCKER ?= docker run --rm -v $(PROJECT_ROOT_PATH):$(PROJECT_ROOT_PATH) -w $(CURDIR) mdashnet/picow

PICO_SDK_PATH ?= /pico-sdk
FREERTOS_KERNEL_PATH ?= /FreeRTOS-Kernel
ELF2UF2 ?= elf2uf2

ASM_FLAGS = -mcpu=cortex-m0plus -mthumb -Os -DNDEBUG   -Wall -Wno-format -Wno-unused-function -Wno-maybe-uninitialized -Wno-unused-variable -ffunction-sections -fdata-sections
C_FLAGS   = $(ASM_FLAGS) -std=gnu11
CXX_FLAGS = $(ASM_FLAGS) -fno-exceptions -fno-unwind-tables -fno-rtti -fno-use-cxa-atexit -std=gnu++17
DEFINES =   -DCFG_TUSB_DEBUG=0 -DCFG_TUSB_MCU=OPT_MCU_RP2040 -DCFG_TUSB_OS=OPT_OS_PICO -DCYW43_LWIP=1 -DFREERTOS_KERNEL_SMP=0 -DLIB_FREERTOS_KERNEL=1 -DLIB_PICO_BIT_OPS=1 -DLIB_PICO_BIT_OPS_PICO=1 -DLIB_PICO_CYW43_ARCH=1 -DLIB_PICO_DIVIDER=1 -DLIB_PICO_DIVIDER_HARDWARE=1 -DLIB_PICO_DOUBLE=1 -DLIB_PICO_DOUBLE_PICO=1 -DLIB_PICO_FIX_RP2040_USB_DEVICE_ENUMERATION=1 -DLIB_PICO_FLOAT=1 -DLIB_PICO_FLOAT_PICO=1 -DLIB_PICO_INT64_OPS=1 -DLIB_PICO_INT64_OPS_PICO=1 -DLIB_PICO_MALLOC=1 -DLIB_PICO_MEM_OPS=1 -DLIB_PICO_MEM_OPS_PICO=1 -DLIB_PICO_PLATFORM=1 -DLIB_PICO_PRINTF=1 -DLIB_PICO_PRINTF_PICO=1 -DLIB_PICO_RUNTIME=1 -DLIB_PICO_STANDARD_LINK=1 -DLIB_PICO_STDIO=1 -DLIB_PICO_STDIO_UART=1 -DLIB_PICO_STDIO_USB=1 -DLIB_PICO_STDLIB=1 -DLIB_PICO_SYNC=1 -DLIB_PICO_SYNC_CORE=1 -DLIB_PICO_SYNC_CRITICAL_SECTION=1 -DLIB_PICO_SYNC_MUTEX=1 -DLIB_PICO_SYNC_SEM=1 -DLIB_PICO_TIME=1 -DLIB_PICO_UNIQUE_ID=1 -DLIB_PICO_UTIL=1 -DLWIP_PROVIDE_ERRNO=1 -DLWIP_SOCKET=1 -DMG_ARCH=6 -DMG_ENABLE_PACKED_FS=1 -DNO_SYS=0 -DPICO_BOARD=\"pico_w\" -DPICO_BUILD=1 -DPICO_CMAKE_BUILD_TYPE=\"Release\" -DPICO_CONFIG_RTOS_ADAPTER_HEADER=$(FREERTOS_KERNEL_PATH)/portable/ThirdParty/GCC/RP2040/include/freertos_sdk_config.h -DPICO_COPY_TO_RAM=0 -DPICO_CXX_ENABLE_EXCEPTIONS=0 -DPICO_CYW43_ARCH_FREERTOS=1 -DPICO_NO_FLASH=0 -DPICO_NO_HARDWARE=0 -DPICO_ON_DEVICE=1 -DPICO_TARGET_NAME=\"picow_web_dashboard\" -DPICO_USE_BLOCKED_RAM=0 -DPING_USE_SOCKETS=1 -DWIFI_PASSWORD=\"$(WIFI_PASSWORD)\" -DWIFI_SSID=\"$(WIFI_SSID)\"

INCLUDES = -I. -I./sdk-prebuilt \
		   -I$(PICO_SDK_PATH) -I$(PICO_SDK_PATH)/lib/lwip/contrib/apps/ping -I$(PICO_SDK_PATH)/src/rp2_common/pico_cyw43_arch/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_unique_id/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_flash/include -I$(PICO_SDK_PATH)/src/common/pico_base/include -I$(PICO_SDK_PATH)/src/boards/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_platform/include -I$(PICO_SDK_PATH)/src/rp2040/hardware_regs/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_base/include -I$(PICO_SDK_PATH)/src/rp2040/hardware_structs/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_claim/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_sync/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_bootrom/include -I$(PICO_SDK_PATH)/lib/cyw43-driver/src -I$(PICO_SDK_PATH)/lib/cyw43-driver/firmware -I$(PICO_SDK_PATH)/src/common/pico_stdlib/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_gpio/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_irq/include -I$(PICO_SDK_PATH)/src/common/pico_sync/include -I$(PICO_SDK_PATH)/src/common/pico_time/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_timer/include -I$(PICO_SDK_PATH)/src/common/pico_util/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_uart/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_divider/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_runtime/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_clocks/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_resets/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_pll/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_vreg/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_watchdog/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_xosc/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_printf/include -I$(PICO_SDK_PATH)/src/common/pico_bit_ops/include -I$(PICO_SDK_PATH)/src/common/pico_divider/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_double/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_int64_ops/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_float/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_malloc/include -I$(PICO_SDK_PATH)/src/rp2_common/boot_stage2/include -I$(PICO_SDK_PATH)/src/common/pico_binary_info/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_stdio/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_stdio_uart/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_stdio_usb/include -I$(PICO_SDK_PATH)/lib/tinyusb/src -I$(PICO_SDK_PATH)/lib/tinyusb/src/common -I$(PICO_SDK_PATH)/lib/tinyusb/hw -I$(PICO_SDK_PATH)/src/rp2_common/pico_fix/rp2040_usb_device_enumeration/include -I$(PICO_SDK_PATH)/src/common/pico_usb_reset_interface/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_pio/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_dma/include -I$(PICO_SDK_PATH)/src/rp2_common/hardware_exception/include -I$(PICO_SDK_PATH)/lib/lwip/src/include -I$(PICO_SDK_PATH)/lib/lwip/contrib/ports/freertos/include -I$(PICO_SDK_PATH)/src/rp2_common/pico_lwip/include \
		   -I$(FREERTOS_KERNEL_PATH)/portable/ThirdParty/GCC/RP2040/include -I$(FREERTOS_KERNEL_PATH)/include

SOURCES_ASM = $(PICO_SDK_PATH)/src/rp2_common/hardware_irq/irq_handler_chain.S $(PICO_SDK_PATH)/src/rp2_common/hardware_divider/divider.S $(PICO_SDK_PATH)/src/rp2_common/pico_bit_ops/bit_ops_aeabi.S $(PICO_SDK_PATH)/src/rp2_common/pico_divider/divider.S $(PICO_SDK_PATH)/src/rp2_common/pico_double/double_aeabi.S $(PICO_SDK_PATH)/src/rp2_common/pico_double/double_v1_rom_shim.S $(PICO_SDK_PATH)/src/rp2_common/pico_int64_ops/pico_int64_ops_aeabi.S $(PICO_SDK_PATH)/src/rp2_common/pico_float/float_aeabi.S $(PICO_SDK_PATH)/src/rp2_common/pico_float/float_v1_rom_shim.S $(PICO_SDK_PATH)/src/rp2_common/pico_mem_ops/mem_ops_aeabi.S $(PICO_SDK_PATH)/src/rp2_common/pico_standard_link/crt0.S

SOURCES_CXX_PICO_SDK = $(PICO_SDK_PATH)/src/rp2_common/pico_standard_link/new_delete.cpp

SOURCES_C_PICO_SDK = \
	$(PICO_SDK_PATH)/lib/cyw43-driver/src/cyw43_ll.c $(PICO_SDK_PATH)/lib/cyw43-driver/src/cyw43_stats.c $(PICO_SDK_PATH)/lib/cyw43-driver/src/cyw43_lwip.c $(PICO_SDK_PATH)/lib/cyw43-driver/src/cyw43_ctrl.c \
	$(PICO_SDK_PATH)/src/common/pico_sync/sem.c $(PICO_SDK_PATH)/src/common/pico_sync/lock_core.c $(PICO_SDK_PATH)/src/common/pico_time/time.c $(PICO_SDK_PATH)/src/common/pico_time/timeout_helper.c $(PICO_SDK_PATH)/src/common/pico_util/datetime.c $(PICO_SDK_PATH)/src/common/pico_util/pheap.c $(PICO_SDK_PATH)/src/common/pico_util/queue.c $(PICO_SDK_PATH)/src/common/pico_sync/mutex.c $(PICO_SDK_PATH)/src/common/pico_sync/critical_section.c \
	$(PICO_SDK_PATH)/src/rp2_common/hardware_uart/uart.c $(PICO_SDK_PATH)/src/rp2_common/pico_runtime/runtime.c $(PICO_SDK_PATH)/src/rp2_common/hardware_clocks/clocks.c $(PICO_SDK_PATH)/src/rp2_common/hardware_pll/pll.c $(PICO_SDK_PATH)/src/rp2_common/hardware_vreg/vreg.c $(PICO_SDK_PATH)/src/rp2_common/hardware_watchdog/watchdog.c $(PICO_SDK_PATH)/src/rp2_common/hardware_xosc/xosc.c $(PICO_SDK_PATH)/src/rp2_common/pico_printf/printf.c $(PICO_SDK_PATH)/src/rp2_common/pico_double/double_init_rom.c $(PICO_SDK_PATH)/src/rp2_common/pico_double/double_math.c $(PICO_SDK_PATH)/src/rp2_common/pico_float/float_init_rom.c $(PICO_SDK_PATH)/src/rp2_common/pico_malloc/pico_malloc.c $(PICO_SDK_PATH)/src/rp2_common/pico_standard_link/binary_info.c $(PICO_SDK_PATH)/src/rp2_common/pico_stdio/stdio.c $(PICO_SDK_PATH)/src/rp2_common/pico_stdio_uart/stdio_uart.c $(PICO_SDK_PATH)/src/rp2_common/pico_stdio_usb/reset_interface.c $(PICO_SDK_PATH)/src/rp2_common/pico_stdio_usb/stdio_usb.c $(PICO_SDK_PATH)/src/rp2_common/pico_stdio_usb/stdio_usb_descriptors.c $(PICO_SDK_PATH)/src/rp2_common/pico_fix/rp2040_usb_device_enumeration/rp2040_usb_device_enumeration.c $(PICO_SDK_PATH)/src/rp2_common/hardware_pio/pio.c $(PICO_SDK_PATH)/src/rp2_common/hardware_dma/dma.c $(PICO_SDK_PATH)/src/rp2_common/hardware_exception/exception.c $(PICO_SDK_PATH)/src/rp2_common/pico_lwip/random.c $(PICO_SDK_PATH)/src/rp2_common/pico_stdlib/stdlib.c $(PICO_SDK_PATH)/src/rp2_common/hardware_gpio/gpio.c $(PICO_SDK_PATH)/src/rp2_common/hardware_irq/irq.c $(PICO_SDK_PATH)/src/rp2_common/pico_cyw43_arch/cyw43_arch.c $(PICO_SDK_PATH)/src/rp2_common/pico_cyw43_arch/cyw43_arch_poll.c $(PICO_SDK_PATH)/src/rp2_common/pico_cyw43_arch/cyw43_arch_threadsafe_background.c $(PICO_SDK_PATH)/src/rp2_common/pico_cyw43_arch/cyw43_arch_freertos.c $(PICO_SDK_PATH)/src/rp2_common/pico_unique_id/unique_id.c $(PICO_SDK_PATH)/src/rp2_common/hardware_flash/flash.c $(PICO_SDK_PATH)/src/rp2_common/hardware_claim/claim.c $(PICO_SDK_PATH)/src/rp2_common/pico_platform/platform.c $(PICO_SDK_PATH)/src/rp2_common/hardware_sync/sync.c $(PICO_SDK_PATH)/src/rp2_common/pico_bootrom/bootrom.c $(PICO_SDK_PATH)/src/rp2_common/cyw43_driver/cyw43_bus_pio_spi.c $(PICO_SDK_PATH)/src/rp2_common/hardware_timer/timer.c \
	$(PICO_SDK_PATH)/lib/tinyusb/src/portable/raspberrypi/rp2040/dcd_rp2040.c $(PICO_SDK_PATH)/lib/tinyusb/src/portable/raspberrypi/rp2040/rp2040_usb.c $(PICO_SDK_PATH)/lib/tinyusb/src/device/usbd.c $(PICO_SDK_PATH)/lib/tinyusb/src/device/usbd_control.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/audio/audio_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/cdc/cdc_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/dfu/dfu_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/dfu/dfu_rt_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/hid/hid_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/midi/midi_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/msc/msc_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/net/ecm_rndis_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/net/ncm_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/usbtmc/usbtmc_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/vendor/vendor_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/class/video/video_device.c $(PICO_SDK_PATH)/lib/tinyusb/src/tusb.c $(PICO_SDK_PATH)/lib/tinyusb/src/common/tusb_fifo.c \
	$(PICO_SDK_PATH)/lib/lwip/contrib/apps/ping/ping.c $(PICO_SDK_PATH)/lib/lwip/src/core/init.c $(PICO_SDK_PATH)/lib/lwip/src/core/def.c $(PICO_SDK_PATH)/lib/lwip/src/core/dns.c $(PICO_SDK_PATH)/lib/lwip/src/core/inet_chksum.c $(PICO_SDK_PATH)/lib/lwip/src/core/ip.c $(PICO_SDK_PATH)/lib/lwip/src/core/mem.c $(PICO_SDK_PATH)/lib/lwip/src/core/memp.c $(PICO_SDK_PATH)/lib/lwip/src/core/netif.c $(PICO_SDK_PATH)/lib/lwip/src/core/pbuf.c $(PICO_SDK_PATH)/lib/lwip/src/core/raw.c $(PICO_SDK_PATH)/lib/lwip/src/core/stats.c $(PICO_SDK_PATH)/lib/lwip/src/core/sys.c $(PICO_SDK_PATH)/lib/lwip/src/core/altcp.c $(PICO_SDK_PATH)/lib/lwip/src/core/altcp_alloc.c $(PICO_SDK_PATH)/lib/lwip/src/core/altcp_tcp.c $(PICO_SDK_PATH)/lib/lwip/src/core/tcp.c $(PICO_SDK_PATH)/lib/lwip/src/core/tcp_in.c $(PICO_SDK_PATH)/lib/lwip/src/core/tcp_out.c $(PICO_SDK_PATH)/lib/lwip/src/core/timeouts.c $(PICO_SDK_PATH)/lib/lwip/src/core/udp.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/acd.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/autoip.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/dhcp.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/etharp.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/icmp.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/igmp.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/ip4_frag.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/ip4.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv4/ip4_addr.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/dhcp6.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/ethip6.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/icmp6.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/inet6.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/ip6.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/ip6_addr.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/ip6_frag.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/mld6.c $(PICO_SDK_PATH)/lib/lwip/src/core/ipv6/nd6.c $(PICO_SDK_PATH)/lib/lwip/src/api/api_lib.c $(PICO_SDK_PATH)/lib/lwip/src/api/api_msg.c $(PICO_SDK_PATH)/lib/lwip/src/api/err.c $(PICO_SDK_PATH)/lib/lwip/src/api/if_api.c $(PICO_SDK_PATH)/lib/lwip/src/api/netbuf.c $(PICO_SDK_PATH)/lib/lwip/src/api/netdb.c $(PICO_SDK_PATH)/lib/lwip/src/api/netifapi.c $(PICO_SDK_PATH)/lib/lwip/src/api/sockets.c $(PICO_SDK_PATH)/lib/lwip/src/api/tcpip.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ethernet.c $(PICO_SDK_PATH)/lib/lwip/src/netif/bridgeif.c $(PICO_SDK_PATH)/lib/lwip/src/netif/bridgeif_fdb.c $(PICO_SDK_PATH)/lib/lwip/src/netif/slipif.c $(PICO_SDK_PATH)/lib/lwip/src/netif/lowpan6_common.c $(PICO_SDK_PATH)/lib/lwip/src/netif/lowpan6.c $(PICO_SDK_PATH)/lib/lwip/src/netif/lowpan6_ble.c $(PICO_SDK_PATH)/lib/lwip/src/netif/zepif.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/auth.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/ccp.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/chap-md5.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/chap_ms.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/chap-new.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/demand.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/eap.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/ecp.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/eui64.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/fsm.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/ipcp.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/ipv6cp.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/lcp.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/magic.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/mppe.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/multilink.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/ppp.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/pppapi.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/pppcrypt.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/pppoe.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/pppol2tp.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/pppos.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/upap.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/utils.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/vj.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/polarssl/arc4.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/polarssl/des.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/polarssl/md4.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/polarssl/md5.c $(PICO_SDK_PATH)/lib/lwip/src/netif/ppp/polarssl/sha1.c $(PICO_SDK_PATH)/lib/lwip/contrib/ports/freertos/sys_arch.c

SOURCES_FREERTOS = $(FREERTOS_KERNEL_PATH)/portable/MemMang/heap_4.c $(FREERTOS_KERNEL_PATH)/portable/ThirdParty/GCC/RP2040/port.c $(FREERTOS_KERNEL_PATH)/croutine.c $(FREERTOS_KERNEL_PATH)/event_groups.c $(FREERTOS_KERNEL_PATH)/list.c $(FREERTOS_KERNEL_PATH)/queue.c $(FREERTOS_KERNEL_PATH)/stream_buffer.c $(FREERTOS_KERNEL_PATH)/tasks.c $(FREERTOS_KERNEL_PATH)/timers.c

SOURCES = main.c mongoose.c net.c packed_fs.c

OBJECTS = $(SOURCES:%.c=obj/%.o) $(SOURCES_C_PICO_SDK:%.c=obj/%.o) $(SOURCES_CXX_PICO_SDK:%.cpp=obj/%.o) $(SOURCES_FREERTOS:%.c=obj/%.o) $(SOURCES_ASM:%.S=obj/%.o)

LINK_FLAGS = -mcpu=cortex-m0plus -mthumb -O3 -DNDEBUG -Wl,--build-id=none --specs=nosys.specs -Wl,--wrap=sprintf -Wl,--wrap=snprintf -Wl,--wrap=vsnprintf -Wl,--wrap=__clzsi2 -Wl,--wrap=__clzdi2 -Wl,--wrap=__ctzsi2 -Wl,--wrap=__ctzdi2 -Wl,--wrap=__popcountsi2 -Wl,--wrap=__popcountdi2 -Wl,--wrap=__clz -Wl,--wrap=__clzl -Wl,--wrap=__clzll -Wl,--wrap=__aeabi_idiv -Wl,--wrap=__aeabi_idivmod -Wl,--wrap=__aeabi_ldivmod -Wl,--wrap=__aeabi_uidiv -Wl,--wrap=__aeabi_uidivmod -Wl,--wrap=__aeabi_uldivmod -Wl,--wrap=__aeabi_dadd -Wl,--wrap=__aeabi_ddiv -Wl,--wrap=__aeabi_dmul -Wl,--wrap=__aeabi_drsub -Wl,--wrap=__aeabi_dsub -Wl,--wrap=__aeabi_cdcmpeq -Wl,--wrap=__aeabi_cdrcmple -Wl,--wrap=__aeabi_cdcmple -Wl,--wrap=__aeabi_dcmpeq -Wl,--wrap=__aeabi_dcmplt -Wl,--wrap=__aeabi_dcmple -Wl,--wrap=__aeabi_dcmpge -Wl,--wrap=__aeabi_dcmpgt -Wl,--wrap=__aeabi_dcmpun -Wl,--wrap=__aeabi_i2d -Wl,--wrap=__aeabi_l2d -Wl,--wrap=__aeabi_ui2d -Wl,--wrap=__aeabi_ul2d -Wl,--wrap=__aeabi_d2iz -Wl,--wrap=__aeabi_d2lz -Wl,--wrap=__aeabi_d2uiz -Wl,--wrap=__aeabi_d2ulz -Wl,--wrap=__aeabi_d2f -Wl,--wrap=sqrt -Wl,--wrap=cos -Wl,--wrap=sin -Wl,--wrap=tan -Wl,--wrap=atan2 -Wl,--wrap=exp -Wl,--wrap=log -Wl,--wrap=ldexp -Wl,--wrap=copysign -Wl,--wrap=trunc -Wl,--wrap=floor -Wl,--wrap=ceil -Wl,--wrap=round -Wl,--wrap=sincos -Wl,--wrap=asin -Wl,--wrap=acos -Wl,--wrap=atan -Wl,--wrap=sinh -Wl,--wrap=cosh -Wl,--wrap=tanh -Wl,--wrap=asinh -Wl,--wrap=acosh -Wl,--wrap=atanh -Wl,--wrap=exp2 -Wl,--wrap=log2 -Wl,--wrap=exp10 -Wl,--wrap=log10 -Wl,--wrap=pow -Wl,--wrap=powint -Wl,--wrap=hypot -Wl,--wrap=cbrt -Wl,--wrap=fmod -Wl,--wrap=drem -Wl,--wrap=remainder -Wl,--wrap=remquo -Wl,--wrap=expm1 -Wl,--wrap=log1p -Wl,--wrap=fma -Wl,--wrap=__aeabi_lmul -Wl,--wrap=__aeabi_fadd -Wl,--wrap=__aeabi_fdiv -Wl,--wrap=__aeabi_fmul -Wl,--wrap=__aeabi_frsub -Wl,--wrap=__aeabi_fsub -Wl,--wrap=__aeabi_cfcmpeq -Wl,--wrap=__aeabi_cfrcmple -Wl,--wrap=__aeabi_cfcmple -Wl,--wrap=__aeabi_fcmpeq -Wl,--wrap=__aeabi_fcmplt -Wl,--wrap=__aeabi_fcmple -Wl,--wrap=__aeabi_fcmpge -Wl,--wrap=__aeabi_fcmpgt -Wl,--wrap=__aeabi_fcmpun -Wl,--wrap=__aeabi_i2f -Wl,--wrap=__aeabi_l2f -Wl,--wrap=__aeabi_ui2f -Wl,--wrap=__aeabi_ul2f -Wl,--wrap=__aeabi_f2iz -Wl,--wrap=__aeabi_f2lz -Wl,--wrap=__aeabi_f2uiz -Wl,--wrap=__aeabi_f2ulz -Wl,--wrap=__aeabi_f2d -Wl,--wrap=sqrtf -Wl,--wrap=cosf -Wl,--wrap=sinf -Wl,--wrap=tanf -Wl,--wrap=atan2f -Wl,--wrap=expf -Wl,--wrap=logf -Wl,--wrap=ldexpf -Wl,--wrap=copysignf -Wl,--wrap=truncf -Wl,--wrap=floorf -Wl,--wrap=ceilf -Wl,--wrap=roundf -Wl,--wrap=sincosf -Wl,--wrap=asinf -Wl,--wrap=acosf -Wl,--wrap=atanf -Wl,--wrap=sinhf -Wl,--wrap=coshf -Wl,--wrap=tanhf -Wl,--wrap=asinhf -Wl,--wrap=acoshf -Wl,--wrap=atanhf -Wl,--wrap=exp2f -Wl,--wrap=log2f -Wl,--wrap=exp10f -Wl,--wrap=log10f -Wl,--wrap=powf -Wl,--wrap=powintf -Wl,--wrap=hypotf -Wl,--wrap=cbrtf -Wl,--wrap=fmodf -Wl,--wrap=dremf -Wl,--wrap=remainderf -Wl,--wrap=remquof -Wl,--wrap=expm1f -Wl,--wrap=log1pf -Wl,--wrap=fmaf -Wl,--wrap=malloc -Wl,--wrap=calloc -Wl,--wrap=realloc -Wl,--wrap=free -Wl,--wrap=memcpy -Wl,--wrap=memset -Wl,--wrap=__aeabi_memcpy -Wl,--wrap=__aeabi_memset -Wl,--wrap=__aeabi_memcpy4 -Wl,--wrap=__aeabi_memset4 -Wl,--wrap=__aeabi_memcpy8 -Wl,--wrap=__aeabi_memset8 -Wl,-z,max-page-size=4096 -Wl,--gc-sections -Wl,--wrap=printf -Wl,--wrap=vprintf -Wl,--wrap=puts -Wl,--wrap=putchar -Wl,--wrap=getchar \
			 -Wl,--script=$(PICO_SDK_PATH)/src/rp2_common/pico_standard_link/memmap_default.ld

LINK_EXTRAS = sdk-prebuilt/bs2_default_padded_checksummed.S sdk-prebuilt/cyw43_resource.o

build:
	$(DOCKER) make docker

docker: $(PROG).uf2

$(PROG).uf2: $(PROG).elf
	@echo Making uf2...
# TODO: Fix this in docker image
	@chmod +x /usr/bin/elf2uf2
	@$(ELF2UF2) $< $@

$(PROG).elf: $(OBJECTS)
	@echo Linking...
	@arm-none-eabi-gcc $(LINK_FLAGS) $(OBJECTS) $(LINK_EXTRAS) -o $@
	@arm-none-eabi-size $@

obj/%.o: %.c
	@mkdir -p $(dir $@)
	@echo Compiling $<
	@arm-none-eabi-gcc $(C_FLAGS) $(INCLUDES) $(DEFINES) $(WIFI) -c $< -o $@

obj/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo Compiling $<
	@arm-none-eabi-g++ $(CXX_FLAGS) $(INCLUDES) $(DEFINES) $(WIFI) -c $< -o $@

obj/%.o: %.S
	@mkdir -p $(dir $@)
	@echo Compiling $<
	@arm-none-eabi-gcc $(ASM_FLAGS) $(INCLUDES) $(DEFINES) $(WIFI) -x assembler-with-cpp -c $< -o $@

clean:
	@rm -rf obj firmware.elf firmware.uf2
