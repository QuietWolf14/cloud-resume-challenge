import boto3
from boto3.dynamodb.conditions import Key
import json

ddb_resource = boto3.resource('dynamodb')
table = ddb_resource.Table('CRC_Resume_Attr')
print('loading function')
def lambda_handler(event, context):
  query_response = table.query(KeyConditionExpression=Key('WebpageAttr').eq('VisitorCount'))
  count = int(query_response['Items'][0]['AttrValue'])
  
  update_response = table.update_item(
    Key={
      'WebpageAttr': 'VisitorCount'
    },

    ExpressionAttributeNames={
      '#AttrValue': 'AttrValue'
    },

    ExpressionAttributeValues={
      ':AttrValue': str(count + 1)
    },
    UpdateExpression="SET #AttrValue = :AttrValue",
    ReturnValues='ALL_NEW'
  )
  body = {}
  body['visitor_count'] = update_response['Attributes']['AttrValue']

  # Need to return headers in the lambda code, including the Access-Control-Allow-Origin header
  response = {}
  response['statusCode'] = 200
  response['headers'] = {}
  response['headers']['Content-Type'] = 'application/json'
  response['headers']['Access-Control-Allow-Origin'] = '*'
  response['headers']['Access-Control-Allow-Methods'] = 'OPTIONS,POST,GET'
  response['headers']['Access-Control-Allow-Headers'] = 'Content-Type'
  response['body'] = json.dumps(body)

  return response
