const express = require("express");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

app.use("/users", require("./routes/user.routes"));
app.use("/groupes", require("./routes/groupe.routes"));
app.use("/messages", require("./routes/message.routes"));

const db = require("./db");

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

// WebSocket
io.on("connection", (socket) => {
  console.log("✅ WebSocket connecté");

  socket.on("joinGroup", (groupeId) => {
    socket.join(`groupe_${groupeId}`);
    console.log(`👥 Rejoint groupe_${groupeId}`);
  });

  socket.on("disconnect", () => {
    console.log("🛑 WebSocket déconnecté");
  });
});

// Envoi message
app.post("/messages", (req, res) => {
  const { id_utilisateur, id_groupe, contenu } = req.body;

  if (!id_utilisateur || !id_groupe || !contenu) {
    return res.status(400).json({ error: "Champs manquants" });
  }

  const sql = `
    INSERT INTO Messages_Groupes ( contenu ,id_utilisateur, id_groupe)
    VALUES (?, ?, ?)`;

  db.query(sql, [contenu, id_utilisateur, id_groupe], (err, result) => {
    if (err) return res.status(500).json({ error: "Erreur SQL" });

    const message = {
      id_message: result.insertId,
      id_utilisateur,
      id_groupe,
      contenu,
      date_envoi: new Date(),
    };

    io.to(`groupe_${id_groupe}`).emit("newMessage", message);
    res.status(201).json(message);
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`✅ API & WebSocket sur le port ${PORT}`));
