import http from "k6/http"
import { sleep, check } from "k6"

export const options = {
  stages: [
    { duration: "30s", target: 20 }, // Aumentar para 20 usuários em 30 segundos
    { duration: "1m", target: 20 }, // Manter 20 usuários por 1 minuto
    { duration: "30s", target: 0 }, // Reduzir para 0 usuários em 30 segundos
  ],
  thresholds: {
    http_req_duration: ["p(95)<500"], // 95% das requisições devem ser concluídas em menos de 500ms
    http_req_failed: ["rate<0.01"], // Menos de 1% das requisições podem falhar
  },
}

// Simular login e obter token
function login() {
  const payload = JSON.stringify({
    email: "admin@exemplo.com",
    password: "senha123",
  })

  const params = {
    headers: {
      "Content-Type": "application/json",
    },
  }

  const loginRes = http.post("http://localhost:3000/api/auth/login", payload, params)
  check(loginRes, {
    "login successful": (r) => r.status === 200,
    "has token": (r) => JSON.parse(r.body).token !== undefined,
  })

  return JSON.parse(loginRes.body).token
}

export default function () {
  const token = login()
  const authParams = {
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
  }

  // Testar página inicial
  const homeRes = http.get("http://localhost:3000/dashboard", authParams)
  check(homeRes, {
    "dashboard status is 200": (r) => r.status === 200,
  })
  sleep(1)

  // Testar listagem de pacientes
  const pacientesRes = http.get("http://localhost:3000/api/pacientes", authParams)
  check(pacientesRes, {
    "pacientes status is 200": (r) => r.status === 200,
    "pacientes has data": (r) => JSON.parse(r.body).data !== undefined,
  })
  sleep(1)

  // Testar listagem de consultas
  const consultasRes = http.get("http://localhost:3000/api/consultas", authParams)
  check(consultasRes, {
    "consultas status is 200": (r) => r.status === 200,
    "consultas has data": (r) => JSON.parse(r.body).data !== undefined,
  })
  sleep(1)

  // Testar criação de paciente
  const pacientePayload = JSON.stringify({
    nome: `Paciente Teste ${Math.floor(Math.random() * 1000)}`,
    email: `teste${Math.floor(Math.random() * 1000)}@exemplo.com`,
    telefone: "(11) 99999-9999",
  })

  const createPacienteRes = http.post("http://localhost:3000/api/pacientes", pacientePayload, authParams)
  check(createPacienteRes, {
    "create paciente status is 200": (r) => r.status === 200 || r.status === 201,
  })

  sleep(3)
}

