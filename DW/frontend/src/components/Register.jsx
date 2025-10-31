import React, { useState } from 'react';
import api from '../api/api'; // Sua instância configurada do Axios
import { useNavigate } from 'react-router-dom';

function Register() {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            // 1. Envia os dados para a rota de registro do backend
            await api.post('/auth/register', { email, password });
            
            // 2. Notifica o usuário e redireciona para o login
            alert('Usuário registrado com sucesso! Faça o login.');
            navigate('/login');
            
        } catch (error) {
            // 3. Trata erros, como 'Email já cadastrado'
            const message = error.response?.data?.message || 'Erro ao registrar. Tente novamente.';
            alert(message);
        }
    };

    return (
        <div style={{ padding: '20px' }}>
            <h2>Registro de Usuário</h2>
            <form onSubmit={handleSubmit}>
                <input 
                    type="email" 
                    value={email} 
                    onChange={(e) => setEmail(e.target.value)} 
                    placeholder="Email" 
                    required 
                />
                <br /><br />
                <input 
                    type="password" 
                    value={password} 
                    onChange={(e) => setPassword(e.target.value)} 
                    placeholder="Senha" 
                    required 
                />
                <br /><br />
                <button type="submit">Registrar</button>
            </form>
        </div>
    );
}

export default Register;