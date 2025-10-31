// backend/server.js
require('dotenv').config(); // Isso deve ser a primeira linha
const express = require('express');
const cors = require('cors'); // Habilita a comunicação entre domínios

// Importa suas rotas de autenticação e rotas privadas
const authRoutes = require('./src/routes/auth.routes');
const privateRoutes = require('./src/routes/private.routes');
const app = express();
const PORT = process.env.PORT || 5000; // Define a porta, com 5000 como fallback

// Middlewares
app.use(cors());
app.use(express.json()); // Permite que a API leia JSON
    // Rotas públicas (como login e registro)
app.use('/api/auth', authRoutes); // Qualquer requisição para /api/auth... vai para auth.routes.js
    // Rotas protegidas (são as que exigem um token válido)
app.use('/api', privateRoutes);
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
