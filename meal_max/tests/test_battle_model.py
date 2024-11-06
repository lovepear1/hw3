import unittest
from meal_max.models.battle_model import BattleModel
from meal_max.models.kitchen_model import Meal
from unittest.mock import patch

class TestBattleModel(unittest.TestCase):

    def setUp(self):
        """Set up a BattleModel instance and prepare meals."""
        self.battle_model = BattleModel()
        self.meal1 = Meal(id=1, meal="Pasta", cuisine="Italian", price=15, difficulty="MED")
        self.meal2 = Meal(id=2, meal="Burger", cuisine="American", price=10, difficulty="LOW")

    def test_prep_combatant(self):
        """Test adding a combatant to the battle."""
        self.battle_model.prep_combatant(self.meal1)
        self.assertIn(self.meal1, self.battle_model.get_combatants())

    def test_battle(self):
        """Test a battle outcome between two meals."""
        self.battle_model.prep_combatant(self.meal1)
        self.battle_model.prep_combatant(self.meal2)

        with patch('meal_max.models.battle_model.get_random', return_value=0.3):
            winner = self.battle_model.battle()
            self.assertIn(winner, [self.meal1.meal, self.meal2.meal])

    def test_clear_combatants(self):
        """Test clearing the combatants list."""
        self.battle_model.prep_combatant(self.meal1)
        self.battle_model.clear_combatants()
        self.assertEqual(len(self.battle_model.get_combatants()), 0)

if __name__ == '__main__':
    unittest.main()
