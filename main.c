// Copyright (c) 2020-2022 Cesanta Software Limited
// All rights reserved

#include "pico/cyw43_arch.h"
#include "pico/stdlib.h"

#include "lwip/ip4_addr.h"

#include "FreeRTOS.h"
#include "task.h"
#include "ping.h"
#include "mongoose.h"

#include "lwip/pbuf.h"
#include "lwip/tcp.h"


#define TEST_TASK_PRIORITY				( tskIDLE_PRIORITY + 1UL )

void device_dashboard_fn(struct mg_connection *, int, void *, void *);

static struct mg_mgr mgr;
static const char *s_listening_address = "http://0.0.0.0:80";

void main_task(__unused void *params) {
    if (cyw43_arch_init()) {
        printf("failed to initialise\n");
        return;
    }
    cyw43_arch_enable_sta_mode();
    printf("Connecting to WiFi...\n");
    if (cyw43_arch_wifi_connect_timeout_ms(WIFI_SSID, WIFI_PASSWORD, CYW43_AUTH_WPA2_AES_PSK, 30000)) {
        printf("failed to connect.\n");
        exit(1);
    } else {
        printf("Connected.\n");
    }

    mg_mgr_init(&mgr);
    mg_http_listen(&mgr, s_listening_address, device_dashboard_fn, &mgr); // Web listener

    while(true) {
        mg_mgr_poll(&mgr, 1000);
    }

    cyw43_arch_deinit();
}

void vLaunch( void) {
    TaskHandle_t task;
    xTaskCreate(main_task, "TestMainThread", configMINIMAL_STACK_SIZE, NULL, TEST_TASK_PRIORITY, &task);
    vTaskStartScheduler();
}

int main( void )
{
    stdio_init_all();
    vLaunch();

    return 0;
}
