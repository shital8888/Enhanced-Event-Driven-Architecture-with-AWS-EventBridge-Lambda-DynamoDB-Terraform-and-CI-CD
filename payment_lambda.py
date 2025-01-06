import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('EventTable')

def lambda_handler(event, context):
    try:
        # Process Payment Event
        event_id = event.get('id')
        data = {
            'eventId': event_id,
            'type': 'Payment',
            'details': event.get('details', {})
        }
        table.put_item(Item=data)
        return {"statusCode": 200, "body": "Payment Processed"}
    except Exception as e:
        return {"statusCode": 500, "body": str(e)}
