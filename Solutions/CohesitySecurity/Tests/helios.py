#!/usr/bin/env python3

import requests
import datetime
import datetime
import time


def get_alerts_details(alert_ids, apiKey):
    maxAlerts = len(alert_ids)
    alert_ids = ",".join(alert_ids)
    api_url = "https://helios.cohesity.com/mcm/alerts?maxAlerts=" + str(maxAlerts) + "&alertIdList=" + alert_ids
    headers = {"Content-Type": "application/json"}
    headers["authority"] = "helios.cohesity.com"
    headers["apiKey"] = apiKey
    response = requests.get(api_url, headers=headers)
    return response.json() if response.json() else None


def get_alert_details(alert_id, apiKey):
    api_url = "https://helios.cohesity.com/mcm/alerts?maxAlerts=1&alertIdList=" + alert_id
    headers = {"Content-Type": "application/json"}
    headers["authority"] = "helios.cohesity.com"
    headers["apiKey"] = apiKey
    response = requests.get(api_url, headers=headers)
    return response.json()[0] if response.json() else None


def get_alerts(apiKey, startDaysAgos=30, endDaysAgos=10):
    def get_days_ago_timestamp(daysAgos=10):
        days_ago = datetime.datetime.now() - datetime.timedelta(days=daysAgos)
        days_ago_timestamp = int(time.mktime(days_ago.timetuple()) * 1000000)
        return str(days_ago_timestamp)

    api_url = "https://helios.cohesity.com/mcm/alerts?alertCategoryList=kSecurity&startDateUsecs=" + get_days_ago_timestamp(startDaysAgos) + "&endDateUsecs=" + get_days_ago_timestamp(endDaysAgos)
    headers = {"Content-Type": "application/json"}
    headers["authority"] = "helios.cohesity.com"
    headers["apiKey"] = apiKey
    response = requests.get(api_url, headers=headers)
    return [jsObj["id"] for jsObj in response.json()]


__all__ = [
    'get_alert_details',
    'get_alerts',
    'get_alerts_details',
]
