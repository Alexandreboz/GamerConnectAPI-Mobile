const Event = require("../models/evenement.model");

exports.getEvents = (req, res) => {
  Event.getAllEvents((err, results) => {
    if (err) return res.status(500).json(err);
    res.json(results);
  });
};

exports.getEventById = (req, res) => {
  Event.getEventById(req.params.id, (err, results) => {
    if (err) return res.status(500).json(err);
    if (results.length === 0) return res.status(404).json({ message: "Événement non trouvé" });
    res.json(results[0]);
  });
};