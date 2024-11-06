import requests
import unittest
from unittest.mock import patch
from meal_max.utils.random_utils import get_random

class TestRandomUtils(unittest.TestCase):

    @patch('meal_max.utils.random_utils.requests.get')
    def test_get_random_returns_float(self, mock_get):
        """Test that get_random returns a float between 0 and 1 when successful."""
        mock_get.return_value.status_code = 200
        mock_get.return_value.text = "0.45"
        
        result = get_random()
        self.assertIsInstance(result, float)
        self.assertGreaterEqual(result, 0)
        self.assertLessEqual(result, 1)

    @patch('meal_max.utils.random_utils.requests.get')
    def test_get_random_error_handling(self, mock_get):
        """Test that get_random handles request exceptions properly."""
        mock_get.side_effect = requests.exceptions.Timeout
        
        with self.assertRaises(RuntimeError):
            get_random()

if __name__ == '__main__':
    unittest.main()
