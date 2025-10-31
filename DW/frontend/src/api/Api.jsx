import axios from 'axios';

// Cria uma instância do Axios com a URL base do seu backend
const api = axios.create({
    baseURL: 'http://localhost:5000/api'
});

// Adiciona um interceptor para injetar o token no cabeçalho de cada requisição
api.interceptors.request.use(config => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
}, error => {
  return Promise.reject(error);
});

export default api;
