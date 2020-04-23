#include <application.h>

// Find defailed API description at https://sdk.hardwario.com/

// LED instance
bc_led_t led;

// Button instance
bc_button_t button;

// Button event callback
void button_event_handler(bc_button_t *self, bc_button_event_t event, void *event_param)
{
    // Log button event
    bc_log_info("APP: Button event: %i", event);

    // Check event source
    if (event == BC_BUTTON_EVENT_PRESS)
    {
        // Toggle LED pin state
        bc_led_set_mode(&led, BC_LED_MODE_TOGGLE);
    }
}

// Application initialization function which is called once after boot
void application_init(void)
{
    // Initialize logging
    bc_log_init(BC_LOG_LEVEL_DUMP, BC_LOG_TIMESTAMP_ABS);

    // Initialize LED
    bc_led_init(&led, BC_GPIO_LED, false, 0);
    bc_led_set_mode(&led, BC_LED_MODE_ON);

    // Initialize button
    bc_button_init(&button, BC_GPIO_BUTTON, BC_GPIO_PULL_DOWN, 0);
    bc_button_set_event_handler(&button, button_event_handler, NULL);
}

// Application task function (optional) which is called peridically if scheduled
void application_task(void)
{
    static int counter;

    // Log task run and increment counter
    bc_log_debug("APP: Task run (count: %d)", ++counter);

    // Plan next run of this task in 1000 ms
    bc_scheduler_plan_current_from_now(1000);
}
