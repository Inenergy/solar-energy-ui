const IS_RPI = process.platform === 'linux' && process.arch == 'arm';

// Идентификатор серийного порта для raspberry OS и windows
const PORT = {
  name: IS_RPI ? '/dev/serial0' : 'COM5',
  baudRate: 230400,
};

// разделители в двоичном виде
const SEPARATORS = Buffer.alloc(4);
SEPARATORS.writeUInt16BE(1573);
SEPARATORS.writeUInt16BE(2605, 2);

// данные с МК
const SERIAL_DATA = ['voltage', 'loadCurrent', 'current', 'isGettingCharacteristic'];

// общая длина массива в байтах для проверки посылок
const DATA_BYTE_LENGTH = SERIAL_DATA.length * 2 + SEPARATORS.length;

// единственная комманда
const COMMANDS = {
  getIVC: [54, 2],
};

module.exports = {
  IS_RPI,
  PORT,
  SEPARATORS,
  COMMANDS,
  SERIAL_DATA,
  DATA_BYTE_LENGTH,
};
