param location string 
param appInsightsResourceId string 

var workbookData = '''{
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 1,
      "content": {
        "json": "# Next Bank Workbook \r\n## SLO Dashboard\r\n### Static Web App Avaliability - 99.7% Uptime Target\r\n"
      },
      "name": "text - 0"
    },
    {
      "type": 10,
      "content": {
        "chartId": "workbook44f835be-5631-4100-80d5-52988edee719",
        "version": "MetricsItem/2.0",
        "size": 0,
        "chartType": 2,
        "resourceType": "microsoft.web/staticsites",
        "metricScope": 0,
        "resourceIds": [
          "/subscriptions/e0b9cada-61bc-4b5a-bd7a-52c606726b3b/resourceGroups/BCSAI2024-DEVOPS-STUDENTS-B-DEV/providers/Microsoft.Web/staticSites/apayne-fe-dev"
        ],
        "timeContext": {
          "durationMs": 2592000000
        },
        "metrics": [
          {
            "namespace": "microsoft.web/staticsites",
            "metric": "microsoft.web/staticsites--SiteHits",
            "aggregation": 7
          }
        ],
        "title": "Static Web App Availability (over 30 Days)",
        "gridFormatType": 1,
        "tileSettings": {
          "titleContent": {
            "formatOptions": {
              "thresholdsOptions": "icons",
              "thresholdsGrid": [
                {
                  "operator": ">=",
                  "thresholdValue": 99.7,
                  "representation": "success"
                },
                {
                  "operator": ">=",
                  "thresholdValue": 99.7,
                  "representation": "warning"
                },
                {
                  "operator": "Default",
                  "representation": "critical"
                }
              ]
            }
          }
        },
        "gridSettings": {
          "rowLimit": 10000
        }
      },
      "name": "metric - 1"
    },
    {
      "type": 1,
      "content": {
        "json": "### Key Vault Avaliability - 99.7% Uptime Avaliability"
      },
      "name": "text - 4"
    },
    {
      "type": 10,
      "content": {
        "chartId": "workbook15eb3ba8-084a-427b-99f7-65a47d7e9bb0",
        "version": "MetricsItem/2.0",
        "size": 0,
        "chartType": 2,
        "resourceType": "microsoft.keyvault/vaults",
        "metricScope": 0,
        "resourceIds": [
          "/subscriptions/e0b9cada-61bc-4b5a-bd7a-52c606726b3b/resourceGroups/BCSAI2024-DEVOPS-STUDENTS-B-DEV/providers/Microsoft.KeyVault/vaults/apayne-kv-dev"
        ],
        "timeContext": {
          "durationMs": 604800000
        },
        "metrics": [
          {
            "namespace": "microsoft.keyvault/vaults",
            "metric": "microsoft.keyvault/vaults--Availability",
            "aggregation": 4
          }
        ],
        "title": "Key Vault Performance (over 7 Days)",
        "gridFormatType": 1,
        "tileSettings": {
          "titleContent": {
            "formatOptions": {
              "thresholdsOptions": "icons",
              "thresholdsGrid": [
                {
                  "operator": ">=",
                  "thresholdValue": 99.9,
                  "representation": "success"
                },
                {
                  "operator": "Default",
                  "representation": "critical"
                }
              ]
            }
          }
        },
        "gridSettings": {
          "rowLimit": 10000
        }
      },
      "name": "metric - 5"
    },
    {
      "type": 1,
      "content": {
        "json": "### App Insights Avaliability - 99.99% Uptime Target"
      },
      "name": "text - 6"
    },
    {
      "type": 10,
      "content": {
        "chartId": "workbook368ca994-07ce-459c-b6df-633df2037d61",
        "version": "MetricsItem/2.0",
        "size": 0,
        "chartType": 2,
        "resourceType": "microsoft.insights/components",
        "metricScope": 0,
        "resourceIds": [
          "/subscriptions/e0b9cada-61bc-4b5a-bd7a-52c606726b3b/resourceGroups/BCSAI2024-DEVOPS-STUDENTS-B-DEV/providers/Microsoft.Insights/components/apayne-appInsights-dev"
        ],
        "timeContext": {
          "durationMs": 2592000000
        },
        "metrics": [
          {
            "namespace": "microsoft.insights/components/kusto",
            "metric": "microsoft.insights/components/kusto-Availability-availabilityResults/availabilityPercentage",
            "aggregation": 4
          }
        ],
        "title": "App Insights Availability (over 30 Days)",
        "gridFormatType": 1,
        "tileSettings": {
          "titleContent": {
            "formatOptions": {
              "thresholdsOptions": "icons",
              "thresholdsGrid": [
                {
                  "operator": ">=",
                  "thresholdValue": 99.9,
                  "representation": "success"
                },
                {
                  "operator": "Default",
                  "representation": "critical"
                }
              ]
            }
          }
        },
        "gridSettings": {
          "rowLimit": 10000
        }
      },
      "name": "metric - 7"
    },
    {
      "type": 1,
      "content": {
        "json": "### HTTP Request Duration - 200ms Target"
      },
      "name": "text - 2"
    },
    {
      "type": 10,
      "content": {
        "chartId": "workbookbff0b743-ab4d-4b6f-8bf1-1827f0429d8b",
        "version": "MetricsItem/2.0",
        "size": 0,
        "chartType": 2,
        "resourceType": "microsoft.web/staticsites",
        "metricScope": 0,
        "resourceIds": [
          "/subscriptions/e0b9cada-61bc-4b5a-bd7a-52c606726b3b/resourceGroups/BCSAI2024-DEVOPS-STUDENTS-B-DEV/providers/Microsoft.Web/staticSites/apayne-fe-dev"
        ],
        "timeContext": {
          "durationMs": 2592000000
        },
        "metrics": [
          {
            "namespace": "microsoft.web/staticsites",
            "metric": "microsoft.web/staticsites--CdnTotalLatency",
            "aggregation": 1
          }
        ],
        "gridSettings": {
          "rowLimit": 10000
        }
      },
      "name": "metric - 3"
    },
    {
      "type": 1,
      "content": {
        "json": "### Failed Requests (over 30 Days) - 5 Count Target"
      },
      "name": "text - 8"
    },
    {
      "type": 10,
      "content": {
        "chartId": "workbookccb100e5-707a-4fae-9354-444a9946e80f",
        "version": "MetricsItem/2.0",
        "size": 0,
        "chartType": 2,
        "resourceType": "microsoft.insights/components",
        "metricScope": 0,
        "resourceIds": [
          "/subscriptions/e0b9cada-61bc-4b5a-bd7a-52c606726b3b/resourceGroups/BCSAI2024-DEVOPS-STUDENTS-B-DEV/providers/Microsoft.Insights/components/apayne-appInsights-dev"
        ],
        "timeContext": {
          "durationMs": 2592000000
        },
        "metrics": [
          {
            "namespace": "microsoft.insights/components/kusto",
            "metric": "microsoft.insights/components/kusto-Failures-requests/failed",
            "aggregation": 1
          }
        ],
        "title": "Security Monitoring (30 Days)",
        "gridFormatType": 1,
        "tileSettings": {
          "titleContent": {
            "formatOptions": {
              "thresholdsOptions": "icons",
              "thresholdsGrid": [
                {
                  "operator": "<=",
                  "thresholdValue": 5,
                  "representation": "success"
                },
                {
                  "operator": "Default",
                  "representation": "critical"
                }
              ]
            }
          }
        },
        "gridSettings": {
          "rowLimit": 10000
        }
      },
      "name": "metric - 9"
    }
  ],
  "fallbackResourceIds": [
    "Azure Monitor"
  ],
  "$schema": "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
}'''


resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('workbook', resourceGroup().id)
  kind: 'shared'
  location: location
  properties: {
    category: 'workflow'
    displayName: 'apayne workflow'
    serializedData: workbookData
    sourceId: appInsightsResourceId
  }
}
