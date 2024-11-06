import unittest
from unittest.mock import patch, MagicMock
from meal_max.models.kitchen_model import create_meal, delete_meal, get_leaderboard, get_meal_by_id, Meal

class TestKitchenModel(unittest.TestCase):

    @patch('meal_max.models.kitchen_model.get_db_connection')
    def test_create_meal_valid(self, mock_get_db):
        """Test creating a meal with valid inputs."""
        mock_conn = MagicMock()
        mock_get_db.return_value = mock_conn
        mock_cursor = mock_conn.cursor.return_value

        create_meal("Pasta", "Italian", 12.5, "MED")

        mock_cursor().execute.assert_called_with(
            "INSERT INTO meals (meal, cuisine, price, difficulty) VALUES (?, ?, ?, ?)",
            ("Pasta", "Italian", 12.5, "MED")
        )
        mock_conn.commit.assert_called_once()

    @patch('meal_max.models.kitchen_model.get_db_connection')
    def test_create_meal_invalid_price(self, mock_get_db):
        """Test creating a meal with an invalid price raises ValueError."""
        with self.assertRaises(ValueError):
            create_meal("Pasta", "Italian", -5, "MED")

    @patch('meal_max.models.kitchen_model.get_db_connection')
    def test_delete_meal_valid_id(self, mock_get_db):
        """Test deleting a meal with a valid ID."""
        mock_conn = MagicMock()
        mock_get_db.return_value = mock_conn
        mock_cursor = mock_conn.cursor.return_value
        
        # Mock the 'deleted' column to be False initially
        mock_cursor.fetchone.side_effect = [[0]]  # Not deleted
        
        delete_meal(1)
        
        # Check that delete was called and committed
        mock_cursor.execute.assert_any_call("UPDATE meals SET deleted = TRUE WHERE id = ?", (1,))
        mock_conn.commit.assert_called_once()

    @patch('meal_max.models.kitchen_model.get_db_connection')
    def test_get_leaderboard_sorted(self, mock_get_db):
        """Test leaderboard sorting by wins and win percentage."""
        mock_conn = MagicMock()
        mock_get_db.return_value = mock_conn
        mock_cursor = mock_conn.cursor.return_value

        # Return two meals that meet leaderboard requirements
        mock_cursor.fetchall.return_value = [
            (1, "Pasta", "Italian", 12.5, "MED", 10, 8, 0.8),
            (2, "Burger", "American", 10, "LOW", 5, 4, 0.8)
        ]

        leaderboard = get_leaderboard(sort_by="wins")
        self.assertEqual(len(leaderboard), 2)
        self.assertEqual(leaderboard[0]['meal'], "Pasta")
        self.assertEqual(leaderboard[1]['meal'], "Burger")

if __name__ == '__main__':
    unittest.main()
