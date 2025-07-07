const Resource = require("../models/ressource.model");

exports.getResources = (req, res) => {
  Resource.getAllResources((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};