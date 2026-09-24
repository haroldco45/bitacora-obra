# Bitácora de Obra Pro

Bitácora diaria de obra pública para contratistas e interventorías. Lleva los folios firmados, calcula el plazo con suspensiones y prórrogas, mide el avance contra el presupuesto oficial, controla las obligaciones del contrato y registra las PQR de la comunidad.

Desarrollada por **Vibras Positivas HM** — Derechos de Autor Reservados.

Demo: https://haroldco45.github.io/bitacora-obra/

## Para qué sirve

En los contratos de obra pública el contratista responde por el plazo, las multas por retraso, los daños a terceros y un largo listado de obligaciones. Cuando llegan las críticas o una reclamación, lo que lo defiende son los documentos: la bitácora diaria, las actas de suspensión y prórroga, los informes y la atención a la comunidad. Esta app los mantiene al día y listos para imprimir.

## Módulos

**Resumen.** Línea de tiempo del plazo, días restantes o de retraso, avance frente al tiempo transcurrido y alertas: plazo vencido con la multa diaria posible, pólizas que no cubren el plazo actual, días sin folio, deberes atrasados y PQR vencidas.

**Bitácora.** Un folio por día con clima y horas perdidas por lluvia, personal, equipos, actividades, cantidades por ítem, observaciones, hasta 4 fotos comprimidas, ubicación GPS y firma en pantalla del residente. Al cerrarse, el folio queda sellado con una huella SHA-256 encadenada al folio anterior. La interventoría agrega su visto bueno con firma, también sellado. Las correcciones se hacen como anotaciones fechadas. La opción *Verificar integridad* detecta cualquier folio alterado después de su cierre. La bitácora completa se imprime foliada para firmar en físico, como exigen los contratos.

**Avance.** Ítems del presupuesto oficial con cantidad y valor unitario. Las cantidades se acumulan desde los folios y el avance se pondera por valor, igual que las actas de cobro.

**Deberes.** Obligaciones del contrato con su frecuencia (una vez, diaria, semanal, mensual o con cada pago) y registro del cumplimiento con su soporte.

**PQR.** Peticiones, quejas y reclamos de vecinos y comerciantes, con radicado consecutivo, plazo de 15 días hábiles (Ley 1755 de 2015, sin descontar festivos) y registro de la respuesta. Incluye aviso de privacidad y autorización según la Ley 1581 de 2012.

**Contrato.** Datos del contrato, acta de inicio, suspensiones con reanudación, prórrogas, adiciones y pólizas con la vigencia que deben cubrir.

**Informe mensual.** Estado del plazo, avance del mes y acumulado, folios, horas perdidas, obligaciones, PQR y actas, listo para imprimir o guardar en PDF.

## Seguridad y datos personales

- Roles por dispositivo: residente, interventor y administrador. El administrador requiere PIN (guardado como hash SHA-256).
- Teléfonos de la comunidad enmascarados salvo para el administrador (Habeas Data, Ley 1581 de 2012).
- Borrar contratos, actas, ítems o pólizas exige PIN de administrador. Los folios cerrados no se pueden borrar.
- Todas las fechas y horas en hora Colombia (UTC-5, America/Bogota).

## Datos y respaldo

Fase 1 (esta versión): los datos viven en el `localStorage` del dispositivo, unos 5 MB. Exporte el respaldo `.json` al menos una vez por semana desde *Más → Ajustes y respaldo* y compártalo por WhatsApp o correo. El respaldo se importa en otro dispositivo para continuar.

Las fotos se comprimen a 1100 px y calidad 60 % (unos 100 a 150 KB cada una). Con 4 fotos diarias el espacio alcanza para unas semanas; la fase 2 las lleva al servidor.

## Contrato de ejemplo

La app arranca con el Contrato de Obra No. 011 de 2026 (EDUAN – Palma Construye SAS, colector del barrio Kennedy, Caucasia), cargado con los datos públicos de SECOP II: valor, plazo, presupuesto por capítulos, pólizas exigidas y obligaciones del contrato. La fecha de inicio es la registrada en SECOP y debe verificarse contra el acta de inicio real. Para un contrato nuevo: *Más → Contrato → Crear otro contrato*.

## Instalación en GitHub Pages

1. Crear el repositorio `bitacora-obra` en la cuenta `haroldco45`.
2. Subir todos los archivos de esta carpeta en la raíz: `index.html`, `manifest.json`, `sw.js`, `icon-192.png`, `icon-512.png`, `apple-touch-icon.png`, `og-image.png`, `README.md` y `schema.sql`.
3. *Settings → Pages → Deploy from a branch → main / root*.
4. Abrir `https://haroldco45.github.io/bitacora-obra/` y usar *Instalar la app*.

Si se publica en otra dirección (Netlify o `vibraspositivashm.com`), actualizar `og:url`, `og:image` y `twitter:image` en `index.html` con la URL absoluta nueva.

Al publicar cambios, subir la versión de `CACHE` en `sw.js` para que los celulares descarguen la actualización.

## Fase 2: multiusuario (Node.js + Express + SQL Server)

`schema.sql` trae el modelo de datos para la versión en servidor: empresas, usuarios con roles por obra, contratos, actas, pólizas, ítems, folios con sus cantidades y fotos, vistos buenos, anotaciones, obligaciones, PQR y auditoría. Un disparador impide modificar o borrar folios cerrados desde la base de datos.

Con el servidor, el residente y el interventor firman desde sus propios celulares sobre el mismo folio, las fotos se guardan en disco con su huella, y se habilitan el radicado de PQR por código QR en la valla de la obra y el portal público de avance para la comunidad.

## Aviso

La app organiza y documenta la ejecución del contrato. No reemplaza la asesoría de un abogado para multas, reclamaciones, prórrogas o liquidaciones.

---

Desarrollada por Vibras Positivas HM — Derechos de Autor Reservados.
