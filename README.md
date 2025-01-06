Problem statement: Develop a solution where events are published to Event Bridge and processed by multiple Lambda functions, such as an Invoice Event handled by an Invoice Lambda and a Payment Event handled by a Payment Lambda. Store the processed data in Dynamo DB. Use Infrastructure as Code (IaC) for infrastructure creation, include unit tests, and adhere to best practices. Enhance the solution further with any additional features to demonstrate your expertise.
Solution overview: 
	Event Publishing to Event Bridge: Set up AWS EventBridge with rules to route events (Invoice and Payment events) to specific Lambda functions.
	Processing with Lambda: Two Lambda functions will process the events—Invoice Lambda for invoices and Payment Lambda for payments.
	Storing Data: Processed data will be stored in a Dynamo DB table.
	Infrastructure as Code: Use Terraform for the entire infrastructure setup.
	Unit Tests: Include unit tests for the Lambda functions.
	Best Practices: Security: Implement IAM roles, least-privilege permissions, and Cloud Watch alarms for monitoring.
Steps to deploy the solution:
1.	 Design the Architecture
Event Publisher: Events are published to Event Bridge 
Event Bridge Rules: Route Invoice Event to Invoice Lambda.
                                 Route Payment Event to Payment Lambda.
Lambdas: Process events and store data in DynamoDB.
Monitoring: Set up Cloud Watch alarms for Lambda invocation errors and DynamoDB throttling.
2.	Terraform IaC Setup
3.	Lambda Function Code (Python)
4.	Unit Tests
5.	Deployment 
Best Practice: I have implement security and monitoring feature in that. 




