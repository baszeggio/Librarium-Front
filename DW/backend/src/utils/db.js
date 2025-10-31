const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '', // Senha do usuário
    database: 'login_jwt', // Nome do banco de dados que criamos
    waitForConnections: true,
    connectionLimit: 10,
});

module.exports = pool;