import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      // Faz a requisição POST para a API de login
      const response = await axios.post('http://localhost:5000/api/auth/login', { email, password });

      // Armazena o token recebido no armazenamento local do navegador
      localStorage.setItem('token', response.data.token);

      alert('Login realizado com sucesso!');
      navigate('/dashboard'); // Redireciona para a página protegida
    } catch (error) {
        alert('Credenciais inválidas. Tente novamente.');
    }
  };

    return (
        <div style={{padding: '20px'}}>
            <h2>Login</h2>
            <form onSubmit={handleSubmit}>
                <input type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder='Email'
                required />
                <br />
                <input type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder='Senha' />
                <br />
                <button type='submit'>Entrar</button>
            </form>
        </div>
    );

}

export default Login;