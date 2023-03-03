#!/usr/bin/env python3
import json


class Alert:
    def __init__(self, json_str):
        data = json.loads(json_str)[0]
        self.jobId = None
        self.clusterId = data['clusterId']
        self.clusterIncarnationId = None
        for prop in data['propertyList']:
            if prop['key'] == 'jobId':
                self.jobId = prop['value']
            elif prop['key'] == 'clusterIncarnationId':
                self.clusterIncarnationId = prop['value']
        self.protectionGroupId = f"{self.clusterId}:{self.clusterIncarnationId}:{self.jobId}"

    def get_jobId(self):
        return self.jobId

    def get_clusterId(self):
        return self.clusterId

    def get_clusterIncarnationId(self):
        return self.clusterIncarnationId

    def get_protectionGroupId(self):
        return self.protectionGroupId
