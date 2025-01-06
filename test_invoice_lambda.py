import unittest
from invoice_lambda import lambda_handler

class TestInvoiceLambda(unittest.TestCase):
    def test_valid_event(self):
        # Test with a valid event structure
        event = {"id": "1234", "details": {"amount": 100}}
        response = lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 200)
        self.assertIn('body', response)
        self.assertIn('success', response['body'].lower())

    def test_invalid_event(self):
        # Test with an invalid event structure
        event = {}
        response = lambda_handler(event, None)
        self.assertEqual(response['statusCode'], 500)
        self.assertIn('body', response)
        self.assertIn('error', response['body'].lower())

if __name__ == '__main__':
    unittest.main()
