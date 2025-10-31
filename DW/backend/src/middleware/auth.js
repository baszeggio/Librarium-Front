const jwt = require('jsonwebtoken');
const verifyToken = (req, res, next) => {

    // Pega o valor do cabeçalho 'Authorization' da requisição
    const authHeader = req.headers['authorization'];

    // O token vem no formato 'Bearer TOKEN', então separamos para pegar apenas o TOKEN
    const token = authHeader && authHeader.split(' ')[1];

    // Se não houver token, o acesso é negado com o código 401 (Unauthorized)
    if (!token) return res.status(401).send('Acesso negado. Token não fornecido.');

    try {
        // Tenta verificar se o token é válido, usando o nosso segredo
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        // Se for válido, adiciona o 'payload' do token na requisição para ser usado depois
        req.user = decoded;
        // Chama a próxima função/middleware na cadeia
        next();
        
    } catch (err) {
    // Se o token for inválido, a resposta é negada com o código 403 (Forbidden)
    res.status(403).send('Token inválido.');
    }
};
module.exports = verifyToken;