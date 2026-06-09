const Badge = require("../models/badge.model");

exports.getBadges = (req, res) => {
  Badge.getAllBadges((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.getBadgeStats = (req, res) => {
  Badge.getBadgeStats((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.getBadgeStatsByGame = (req, res) => {
  Badge.getBadgeStatsByGame((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};