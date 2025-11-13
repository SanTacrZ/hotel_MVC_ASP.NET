using biblioteca_hotel.Clases;

namespace hotel_web_final.Servicios
{
    public class ReservaService
    {
        private readonly List<Reserva> _reservas = new();
        private int _nextId = 1;
        private readonly HabitacionService _habitacionService;
        private readonly ClienteService _clienteService;
        private readonly HuespedService _huespedService;
        private readonly AuditoriaService _auditoriaService;

        public ReservaService(HabitacionService habitacionService, ClienteService clienteService, HuespedService huespedService, AuditoriaService auditoriaService)
        {
            _habitacionService = habitacionService;
            _clienteService = clienteService;
            _huespedService = huespedService;
            _auditoriaService = auditoriaService;
        }

        public Reserva CrearReserva(int clienteId, DateTime fechaEntrada, DateTime fechaSalida, int numHuespedes, List<int> habitacionIds, List<int>? huespedIds = null)
        {
            var cliente = _clienteService.BuscarPorId(clienteId);
            if (cliente == null)
                throw new Exception($"Cliente con ID {clienteId} no encontrado");

            // Asegurar que las fechas sean solo fecha (sin hora) usando DateTime.Today como referencia
            var fechaHoy = DateTime.Today;
            var fechaEntradaNormalizada = fechaEntrada.Date;
            var fechaSalidaNormalizada = fechaSalida.Date;

            // Permitir reservas desde HOY (inclusive) en adelante
            // Usar < (menor que), NO <= (menor o igual), para permitir TODAY
            if (fechaEntradaNormalizada < fechaHoy)
            {
                throw new Exception($"La fecha de entrada no puede ser anterior a hoy. " +
                    $"Fecha entrada: {fechaEntradaNormalizada:yyyy-MM-dd}, " +
                    $"Hoy: {fechaHoy:yyyy-MM-dd}");
            }

            // La fecha de salida debe ser al menos un día después de la entrada
            if (fechaSalidaNormalizada <= fechaEntradaNormalizada)
            {
                throw new Exception("La fecha de salida debe ser posterior a la fecha de entrada");
            }

            var reserva = new Reserva
            {
                Id = _nextId++,
                Cliente = cliente,
                FechaEntrada = fechaEntrada,
                FechaSalida = fechaSalida,
                NumHuespedes = numHuespedes,
                Estado = new EstadoReserva { Nombre = "Pendiente" },
                FechaCreacion = DateTime.Now,
                FechaModificacion = DateTime.Now
            };

            foreach (var habitacionId in habitacionIds)
            {
                var habitacion = _habitacionService.BuscarPorId(habitacionId);
                if (habitacion == null)
                    throw new Exception($"Habitación con ID {habitacionId} no encontrada");

                if (habitacion.Estado != "Disponible")
                    throw new Exception($"La habitación {habitacion.Numero} no está disponible");

                reserva.AsignarHabitacion(habitacion);
                habitacion.Reservar();
            }

            if (huespedIds != null)
            {
                foreach (var huespedId in huespedIds)
                {
                    var huesped = _huespedService.BuscarPorId(huespedId);
                    if (huesped != null)
                    {
                        reserva.Huespedes.Add(huesped);
                    }
                }
            }

            reserva.CalcularPrecioTotal();
            _reservas.Add(reserva);

            // Registrar en auditoría
            _auditoriaService.RegistrarCreacionReserva(
                reserva.Id,
                $"{cliente.Nombre} {cliente.Apellido}",
                fechaEntrada,
                fechaSalida
            );

            return reserva;
        }

        public IEnumerable<Reserva> ObtenerTodas()
        {
            return _reservas;
        }

        public Reserva? BuscarPorId(int id)
        {
            return _reservas.FirstOrDefault(r => r.Id == id);
        }

        public IEnumerable<Reserva> ObtenerPorCliente(int clienteId)
        {
            return _reservas.Where(r => r.Cliente?.IdCliente == clienteId);
        }

        public IEnumerable<Reserva> ObtenerPorFecha(DateTime fecha)
        {
            return _reservas.Where(r => r.FechaEntrada.Date <= fecha.Date && r.FechaSalida.Date >= fecha.Date);
        }

        public void ConfirmarReserva(int id)
        {
            var reserva = BuscarPorId(id);
            if (reserva == null)
                throw new Exception($"Reserva con ID {id} no encontrada");

            reserva.ConfirmarReserva();

            // Registrar en auditoría
            _auditoriaService.RegistrarConfirmacionReserva(id);
        }

        public void CancelarReserva(int id)
        {
            var reserva = BuscarPorId(id);
            if (reserva == null)
                throw new Exception($"Reserva con ID {id} no encontrada");

            // Validar que la cancelación se haga con al menos 24 horas de anticipación
            var horasAnticipacion = (reserva.FechaEntrada - DateTime.Now).TotalHours;
            if (horasAnticipacion < 24)
            {
                throw new Exception($"No se puede cancelar la reserva. Debe cancelar con al menos 24 horas de anticipación al check-in. Tiempo restante: {Math.Max(0, horasAnticipacion):F1} horas.");
            }

            reserva.CancelarReserva();
            foreach (var habitacion in reserva.Habitaciones)
            {
                habitacion.Liberar();
            }

            // Registrar en auditoría
            _auditoriaService.RegistrarCancelacionReserva(id);
        }

        public void ActualizarReserva(Reserva reserva)
        {
            var existente = BuscarPorId(reserva.Id);
            if (existente == null)
                throw new Exception($"Reserva con ID {reserva.Id} no encontrada");

            var index = _reservas.IndexOf(existente);
            reserva.FechaModificacion = DateTime.Now;
            _reservas[index] = reserva;
        }
    }
}

