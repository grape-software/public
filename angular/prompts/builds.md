# Copilot asking prompts

## Buscador de recibos

Con el modelo de datos del endpoint GET /recibos:

```json
{
  "totalCount": 131217,
  "importeTotal": 118466010590.6,
  "saldoTotal": 171062435.84,
  "res": [
    {
      "reciboProvisorioId": 12465,
      "numero": 3620,
      "importe": 103313.48,
      "fechaEmision": "2017-12-04T00:00:00",
      "userId": "4c7aa98d-c66a-44da-b013-e00a56f4e74a",
      "user": null,
      "rendicionId": null,
      "rendicion": null,
      "claveUnicaComprobante": "26293-6",
      "sucursal": 0,
      "fechaAnulado": null,
      "usuarioIdAnulo": null,
      "userAnulo": null,
      "nota": null,
      "clienteId": 2816,
      "cliente": {
        "clienteId": 2816,
        "empresaId": 1,
        "empresa": null,
        "codigo": "C02875",
        "grupoEconomico": null,
        "razonSocial": "BUL.REGINATO SRL",
        "descuento": 34.0,
        "incremento": 0.0,
        "tipoClienteId": "1",
        "tipoCliente": null,
        "cuit": "30-69178984-1",
        "listaId": "5",
        "limiteCredito": 10362513.4,
        "transporte": null,
        "fechaBaja": null,
        "fechaUltimaActualizacion": "2025-11-11T19:25:54.743",
        "marcadorId": null,
        "direccionId": null,
        "direccion": null,
        "estadoActual": null,
        "telefonoPrincipal": null,
        "email": "fernanda@buloneriareginato.com.ar",
        "porcentajeFlete": 5.0,
        "vendedorId": 43,
        "vendedor": null,
        "cobradorId": 102,
        "cobrador": null,
        "clienteUsuario": [],
        "personasClientes": [],
        "contratos": [],
        "comprobantes": [],
        "recibos": [],
        "condicionIvaId": null,
        "provincia": "Tucumán",
        "nombreCompleto": "BUL.REGINATO SRL C02875 - ",
        "codigoPagoElectronico": "000C028755130006305",
        "datosAfip": null,
        "afip": {
          "tipoDocumento": null,
          "codDestFacturacion": null
        }
      },
      "fechaAlta": "2017-12-04T00:00:00",
      "saldo": 0.0,
      "transaccionId": null,
      "estado": "AU",
      "fechaPago": null,
      "descuento": 0.0,
      "empresaId": 1,
      "empresa": null,
      "templateId": null,
      "valores": [],
      "cuotas": [],
      "adelantos": [],
      "comisiones": [],
      "comprobantes": [],
      "numeroFormateado": "0000-00003620",
      "diasPago": 0.0,
      "fechaDescuentoPago": "2017-12-04T00:00:00",
      "aprobado": "2017-12-04T00:00:00",
      "userId_Aprobado": null,
      "userAprobo": null,
      "tipo": "Oficial",
      "usuarioPerfil": "",
      "aprobarBloqueado": false,
      "permiteAprobarAutomatico": false
    }
  ],
  "search": {
    "clienteId": 0,
    "sinConciliar": false,
    "localidad": null,
    "importe": 0.0,
    "numero": 0,
    "conSaldo": false,
    "aprobados": null,
    "sucursal": 0,
    "estado": null,
    "rendicion": false,
    "userId": null,
    "sinClaveUnica": false,
    "vendedorCobradorId": 0,
    "incluirTodosClientes": false,
    "pageIndex": 1,
    "pageSize": 1,
    "sortBy": null,
    "sortValue": null,
    "onlyActive": false,
    "searchText": null,
    "fromDate": null,
    "toDate": null,
    "emailVerified": false,
    "locked": false,
    "rolID": 0
  }
}
```

construir el buscador según la especificación:

- Campos de búsqueda:
  - SearchText
  - Fecha desde y hasta (selector de fecha)
- Columnas de resultados:
  - item.cliente?.razonSocial
  - item.cliente?.cuit
  - item.numeroFormateado
  - item.fechaEmision | date:'dd/MM/yyyy'
  - item.importe | currency:'ARS':'symbol':'1.2-2'
  - item.saldo | currency : 'ARS' : 'symbol':'1.2-2'
  - item.rendicionId
- Botones de acción por fila:
  - Eliminar
  - Ver Detalle
  - Previsualizar
- Diálogos
  - Avanzados con filtros adicionales
    - ID del recibo
    - Importe desde y hasta
    - Vendedor (select a partir del endpoint GET /vendedores, por ahora mockear datos)
    - Aprobados (checkbox)
  - Confirmación de eliminación

Utilizando como base los elementos de angular definidos en ./github/prompts/angular.md siguiendo las mejores prácticas ahí definidas.
