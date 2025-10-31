const router = require('express').Router();

// Importa o middleware de autenticação
const verifyToken = require('../middleware/auth');

// Exemplo de rota protegida
// A função 'verifyToken' é executada antes de a rota principal ser acessada.
// Se o token for inválido, o acesso será negado.
router.get('/protected', verifyToken, (req, res) => {
    // Se a requisição chegou até aqui, significa que o token é válido.
    res.json({ message: 'Acesso garantido, você está autenticado!' });
});

module.exports = router;