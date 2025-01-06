import unittest
from payment_lambda import lambda_handler

class TestPaymentLambda(unittest.TestCase):
    def test_valid_event(self):
        """
        Test case for a valid Payment event
        """
        event = {
            "id": "5678",
            "details": {
                "amount": 200,
                "currency": "USD",
                "status": "Completed"
            }
        }
        response = lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(response['body'], "Payment Processed")

    def test_invalid_event(self):
        """
        Test case for an invalid Payment event
        """
        event = {}  # Missing 'id' and 'details'
        response = lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 500)
        self.assertIn("Error", response['body'])

if __name__ == "__main__":
    unittest.main()
