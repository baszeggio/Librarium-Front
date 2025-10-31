import { useState, useEffect } from 'react';
import axios from '../api/Api';
import { useNavigate } from 'react-router-dom';

function Dashboard() {
    const [message, setMessage] = useState('');
    const navigate = useNavigate();

    useEffect(() => {
        // Esta função tenta acessar a rota protegida do backend
        const fetchProtectedData = async () => {
            try {
                // A requisição usa o interceptador do axios para enviar o token automaticamente
                const response = await axios.get('http://localhost:5000/api/protected');
                setMessage(response.data.message);
            } catch (error) {
                // Se houver um erro, o token estará inválido. Redireciona para o login.
                console.error('Erro ao acessar rota protegida', error);
                localStorage.removeItem('token');
                navigate('/login');
            }
        };
        fetchProtectedData();
    }, [navigate]); // O array garante que o efeito só rode uma vez

    const handleLogout = async () => {
        localStorage.removeItem('token');
        navigate('/login');
    };

    return (
        <div style={{ padding: '20px' }}>
            <h2>Dashboard</h2>
            <p>{message}</p>
            <button onClick={handleLogout}>Sair</button>
        </div>
    );
}

export default Dashboard;
    