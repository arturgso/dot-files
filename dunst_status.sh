#!/bin/bash

STATUS=$(dunstctl is-paused)

if [ "$STATUS" = "true" ]; then
    echo "󰂛"
else
    echo "󰂚"
fi

