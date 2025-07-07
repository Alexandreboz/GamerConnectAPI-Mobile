const Matchmaking = require("../models/matchmaking.model");

exports.getAll = (req, res) => {
  Matchmaking.getAllMatchRequests((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};