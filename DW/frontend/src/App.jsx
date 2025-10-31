import { BrowserRouter as Router, Routes, Route, Link, Navigate } from 'react-router-dom';
import Login from './components/Login.jsx';
import Register from './components/Register.jsx'; // <--- NOVIDADE 1: Importar o componente
import Dashboard from './components/Dashborad.jsx';

// Componente que atua como um 'guarda de rota'
const ProtectedRoute = ({ children }) => {
  const token = localStorage.getItem('token');
  // Se não houver token, redireciona o usuário para a página de login
  if (!token) {
    return <Navigate to="/login" replace />;
  }
  // Se houver token, permite que o componente filho (Dashboard) seja renderizado
  return children;
};

function App() {
  return (
    <Router>
      <nav style={{ marginBottom: '20px' }}>
        <Link to="/">Home</Link> | 
        <Link to="/login">Login</Link> | 
        <Link to="/register">Registro</Link> | {/* <--- NOVIDADE 2: Link para a rota */}
        <Link to="/dashboard">Dashboard</Link>
      </nav>
      <Routes>
        {/* Rotas Públicas */}
        <Route path="/" element={<h2>Página Inicial</h2>} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} /> {/* <--- NOVIDADE 3: Mapeamento da rota */}
        
        {/* Rota Protegida */}
        <Route 
          path="/dashboard" 
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          } 
        />
      </Routes>
    </Router>
  );
}
export default App;