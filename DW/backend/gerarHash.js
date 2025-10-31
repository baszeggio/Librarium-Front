const bcrypt = require('bcryptjs');

const gerarHash = async () => {
    const senhaEmTextoPuro = 'senha123'; // Altere esta senha para o que você quiser
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(senhaEmTextoPuro, salt);
    console.log(hash);
};

gerarHash();

//Execute este arquivo no terminal, dentro da sua pasta backend, com o comando:
//node gerarHash.js
//Copie o hash gerado no terminal e substitua o hash existente no seu usersDb.js.