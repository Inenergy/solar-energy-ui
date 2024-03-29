<script>
  import Button from '../atoms/Button';
  import SaveButton from '../organisms/SaveButton';
  import RadioGroup from '../molecules/RadioGroup';
  import { ipcRenderer } from 'electron';
  import Chart from 'chart.js';
  import 'chartjs-plugin-zoom';
  import configureChart from './chart.config';
  import { onMount } from 'svelte';
  import { serialData } from '../stores';
  import { COMMANDS } from '../constants';
  import Version from '../atoms/Version';
  import UpdateModal from '../organisms/UpdateModal';
  import { __ } from '../utils/translations';
  let updateAvailable = ipcRenderer.sendSync('checkUpdate');

  ipcRenderer.on('updateAvailable', () => (updateAvailable = true));

  onMount(() => {
    chart = new Chart(
      document.getElementById('chart').getContext('2d'),
      configureChart([], { x: 'I, A', y: 'U, V' })
    );
    chart.options.onClick = chart.resetZoom;
  });

  const chartOptions = [
    {
      label: 'I(U)',
      value: 'IVC',
      yLabel: 'U, V',
      yName: 'voltage',
    },
    {
      label: 'I(P)',
      value: 'IWC',
      yLabel: 'P, W',
      yName: 'power',
    },
  ];

  let rows = [],
    saveDisabled = true,
    isActive,
    chart,
    chartOption = chartOptions[0],
    unsubscribeData,
    timeStart = 0;

  function changeAxes(e) {
    if (chartOption.value !== e.target.value) {
      chartOption = chartOptions.find(
        (option) => option.value === e.target.value
      );
      redrawChart();
    }
  }

  function redrawChart() {
    chart.options.scales.yAxes[0].scaleLabel.labelString = chartOption.yLabel;
    chart.data.datasets[0].data = rows
      .map(getPointFromRow)
      .sort((p1, p2) => p1.x - p2.x);
    chart.update();
  }

  function monitorData() {
    unsubscribeData = serialData.subscribe((data) => {
      if (data.isGettingCharacteristic) {
        if (!isActive) startDrawing();
        addPoint(data);
      } else if (isActive) {
        isActive = false;
        unsubscribeData();
      }
    });
  }

  function startDrawing() {
    isActive = true;
    clearChart();
    startLogging();
  }

  function getIVC(e) {
    ipcRenderer.send('serialCommand', COMMANDS.getIVC);
    monitorData();
  }

  function startLogging() {
    const headers = ['t, s', 'U, V', 'I, A', 'P, W'];
    saveDisabled = false;
    ipcRenderer.send('startLog', headers);
  }

  function clearChart() {
    timeStart = 0;
    rows = [];
    chart.data.datasets[0].data = [];
  }

  function addPoint(iv) {
    const prevPoint = rows[rows.length - 1];
    if (
      prevPoint &&
      Math.sign(prevPoint.voltage - iv.voltage) ==
        Math.sign(prevPoint.current - iv.current)
    )
      return;
    const row = {
      seconds: timeStart++,
      voltage: iv.voltage,
      current: iv.current,
      power: iv.voltage * iv.current,
    };
    rows.push(row);
    addToChart(row);
    sendToLogger(row);
  }

  function addToChart(row) {
    chart.data.datasets[0].data.push(getPointFromRow(row));
    chart.data.datasets[0].data.sort((p1, p2) => p1.x - p2.x);
    chart.update();
  }

  function sendToLogger(row) {
    ipcRenderer.send('logRow', formatLogRow(row));
  }

  function getPointFromRow(row) {
    return { x: row.current, y: row[chartOption.yName] };
  }

  function formatLogRow(row) {
    return Object.values(row).map((v, i) => (i > 0 ? v.toFixed(3) : v));
  }
</script>

<div class="layout">
  {#if updateAvailable}
    <UpdateModal />
  {/if}
  <Version />

  <header>
    {$__('solar panels study')}
  </header>
  <main>
    <div class="short-label">{$__('chart type')}</div>
    <RadioGroup
      name="chartAxes"
      options={chartOptions}
      onChange={changeAxes}
      value={chartOption.value}
    />
    <div class="short-label">U, {$__('V')}</div>
    <div class="value">{$serialData.voltage.toFixed(3)}</div>
    <div class="short-label">I, {$__('A')}</div>
    <div class="value">{$serialData.current.toFixed(3)}</div>
    <div class="short-label">P, {$__('W')}</div>
    <div class="value">
      {($serialData.current * $serialData.voltage).toFixed(3)}
    </div>
    <div class="short-label">
      I
      <sub>{$__('load')}</sub>
      , {$__('A')}
    </div>
    <div class="value">{$serialData.loadCurrent.toFixed(3)}</div>
    <div class="chart">
      <canvas id="chart" height="160" />
    </div>
  </main>
  <footer>
    <Button on:click={getIVC} disabled={isActive}
      >{$__('get characteristics')}</Button
    >
    <SaveButton disabled={saveDisabled} />
  </footer>
</div>

<style>
  .layout {
    background: url('../../app/background.svg') no-repeat;
  }
  main {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    grid-template-rows: repeat(8, 1fr);
    grid-column-gap: 24px;
    grid-row-gap: 8px;
    align-items: center;
    padding: 0 24px;
    font-size: 1.8rem;
  }
  .chart {
    grid-area: 1 / 3 / 11 / 13;
  }
  footer {
    justify-content: space-between;
    padding: 0 24px;
  }
  .short-label {
    grid-column: 1 / 2;
    white-space: nowrap;
  }
  .value {
    grid-column: 2 / 3;
    font-family: 'Oswald';
  }
</style>
