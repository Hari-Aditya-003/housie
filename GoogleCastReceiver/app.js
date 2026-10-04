const namespace = 'urn:x-cast:com.housie.board';
const board = document.getElementById('number-board');
const currentNumber = document.getElementById('current-number');
const status = document.getElementById('status');
const progress = document.getElementById('progress');
const numberElements = new Map();

const statusLabels = {
  ready: 'Ready to begin',
  running: 'Calling automatically',
  paused: 'Game paused',
  finished: 'All numbers called'
};

for (let number = 1; number <= 90; number += 1) {
  const cell = document.createElement('div');
  cell.className = 'number';
  cell.textContent = String(number);
  cell.setAttribute('aria-label', `Number ${number}, not called`);
  board.appendChild(cell);
  numberElements.set(number, cell);
}

function render(state) {
  const calledNumbers = Array.isArray(state.calledNumbers) ? state.calledNumbers : [];
  const called = new Set(calledNumbers);

  numberElements.forEach((cell, number) => {
    cell.classList.toggle('called', called.has(number));
    cell.classList.toggle('current', state.currentNumber === number);
    cell.setAttribute('aria-label', `Number ${number}, ${called.has(number) ? 'called' : 'not called'}`);
  });

  currentNumber.textContent = state.currentNumber == null ? '?' : String(state.currentNumber);
  status.textContent = statusLabels[state.status] || statusLabels.ready;
  progress.textContent = `${called.size} of 90 called`;
}

const context = cast.framework.CastReceiverContext.getInstance();
context.addCustomMessageListener(namespace, (event) => {
  try {
    const state = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
    render(state || {});
  } catch (error) {
    console.error('Invalid Housie board update', error);
  }
});

context.start({ disableIdleTimeout: true });
