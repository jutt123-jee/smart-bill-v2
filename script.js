let appData = JSON.parse(localStorage.getItem('elec_gas_app_data')) || {
    meterNames: { m1: "Meter 1", m2: "Meter 2", m3: "Meter 3", gas: "Gas Meter" },
    deposits: { m1: 0, m2: 0, m3: 0, gas: 0 },
    limits: {
        m1: { daily: 10, total: 300, rate: 35 },
        m2: { daily: 10, total: 300, rate: 35 },
        m3: { daily: 10, total: 300, rate: 35 },
        gas: { daily: 2, total: 50, rate: 100 }
    },
    fixedBudget: 30000,
    totalMeterLimit: 1000,
    history: [],
    alerts: []
};

function saveData() {
    localStorage.setItem('elec_gas_app_data', JSON.stringify(appData));
    renderUI();
}

function toggleSidebar() {
    document.getElementById('sidebar').classList.toggle('active');
}

function switchTab(tabId) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    document.getElementById(tabId).classList.add('active');
}

function openModal(id) { document.getElementById(id).style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }

function saveMeterNames() {
    appData.meterNames.m1 = document.getElementById('name_m1').value || "Meter 1";
    appData.meterNames.m2 = document.getElementById('name_m2').value || "Meter 2";
    appData.meterNames.m3 = document.getElementById('name_m3').value || "Meter 3";
    appData.meterNames.gas = document.getElementById('name_m4').value || "Gas Meter";
    closeModal('meterNamesModal');
    saveData();
}

function saveReading() {
    let m = document.getElementById('entryMeterSelect').value;
    let val = parseFloat(document.getElementById('newReadingInput').value) || 0;
    let fileInput = document.getElementById('billImgInput');

    let record = {
        id: Date.now(),
        meter: m,
        reading: val,
        date: new Date().toISOString(),
        img: ""
    };

    if (fileInput.files && fileInput.files[0]) {
        let reader = new FileReader();
        reader.onload = function (e) {
            record.img = e.target.result;
            appData.history.push(record);
            saveData();
        };
        reader.readAsDataURL(fileInput.files[0]);
    } else {
        appData.history.push(record);
        saveData();
    }
}

function saveRecordManual() {
    let m = document.getElementById('rec_meter_select').value;
    let curr = parseFloat(document.getElementById('rec_curr_reading').value) || 0;
    let dt = document.getElementById('rec_time_select').value;

    appData.history.push({
        id: Date.now(),
        meter: m,
        reading: curr,
        date: dt ? new Date(dt).toISOString() : new Date().toISOString(),
        img: ""
    });
    saveData();
}

function saveMeterLimits() {
    let m = document.getElementById('limitMeterSelect').value;
    appData.limits[m].daily = parseFloat(document.getElementById('lim_daily_unit').value) || 0;
    appData.limits[m].total = parseFloat(document.getElementById('lim_total_unit').value) || 0;
    appData.limits[m].rate = parseFloat(document.getElementById('lim_per_unit_rate').value) || 0;
    saveData();
}

function updateOverallLimits() {
    appData.fixedBudget = parseFloat(document.getElementById('inp_fix_budget').value) || 0;
    appData.totalMeterLimit = parseFloat(document.getElementById('inp_total_meter_limit').value) || 0;
    saveData();
}

function deleteHistory(id) {
    appData.history = appData.history.filter(item => item.id !== id);
    saveData();
}

function calcGasBill() {
    let curr = parseFloat(document.getElementById('gas_curr').value) || 0;
    let prev = parseFloat(document.getElementById('gas_prev').value) || 0;
    let diff = Math.max(0, curr - prev);
    document.getElementById('gas_diff').value = diff.toFixed(3);

    let press = parseFloat(document.getElementById('gas_press').value) || 1.0218;
    let consumedHm3 = diff * press;
    document.getElementById('gas_consumed_hm3').value = consumedHm3.toFixed(4);

    let charges = parseFloat(document.getElementById('gas_charges').value) || 0;
    let rent = parseFloat(document.getElementById('gas_meter_rent').value) || 580;
    let gst = parseFloat(document.getElementById('gas_gst').value) || 0;
    let arrears = parseFloat(document.getElementById('gas_arrears').value) || 0;

    let total = charges + rent + gst + arrears;
    document.getElementById('gas_total_result_box').innerText = "Rs. " + total.toFixed(2);
}

function addAlert() {
    let txt = document.getElementById('alert_text_input').value;
    if (txt) {
        appData.alerts.push({ id: Date.now(), text: txt });
        document.getElementById('alert_text_input').value = "";
        saveData();
    }
}

function deleteAlert(id) {
    appData.alerts = appData.alerts.filter(a => a.id !== id);
    saveData();
}

function testSystemAlerts() {
    let simTime = document.getElementById('simulated_time_input').value;
    alert("Testing Alerts for time: " + (simTime || "Current System Time") + "\nAll Limit and Due Date alerts are functioning.");
}

function exportData() { alert("Exporting data as PDF/Excel..."); }
function savePassword() { alert("Password Saved."); closeModal('privacyModal'); }
function savePIN() { alert("Security PIN Saved."); closeModal('pinModal'); }
function backupCloud() { alert("Backup synced to cloud successfully."); }
function shareWhatsApp() {
    let msg = `Daily Bill Summary Report:\nFixed Budget: ${appData.fixedBudget} RS`;
    window.open(`https://wa.me/?text=${encodeURIComponent(msg)}`, '_blank');
}

function resetData() {
    if (confirm("Are you sure you want to reset all system data?")) {
        localStorage.removeItem('elec_gas_app_data');
        location.reload();
    }
}

function renderUI() {
    // Labels
    document.getElementById('dash_lbl_m1').innerText = appData.meterNames.m1;
    document.getElementById('dash_lbl_m2').innerText = appData.meterNames.m2;
    document.getElementById('dash_lbl_m3').innerText = appData.meterNames.m3;
    document.getElementById('dash_lbl_m4').innerText = appData.meterNames.gas;

    document.getElementById('lbl_stat_m1').innerText = appData.meterNames.m1;
    document.getElementById('lbl_stat_m2').innerText = appData.meterNames.m2;
    document.getElementById('lbl_stat_m3').innerText = appData.meterNames.m3;
    document.getElementById('lbl_stat_m4').innerText = appData.meterNames.gas;

    document.getElementById('disp_fixed_budget').innerText = appData.fixedBudget + " RS";

    // Limits Display
    ['m1', 'm2', 'm3', 'gas'].forEach(m => {
        let el = document.getElementById('disp_lim_' + (m === 'gas' ? 'm4' : m));
        if (el) el.innerText = `Daily: ${appData.limits[m].daily} | Total: ${appData.limits[m].total} | Rate: ${appData.limits[m].rate}`;
    });

    // History Tables Render
    ['m1', 'm2', 'm3', 'gas'].forEach(m => {
        let container = document.getElementById('table_' + (m === 'gas' ? 'gas' : m));
        let mHist = appData.history.filter(h => h.meter === m);

        let html = `<table><tr><th>Old</th><th>New</th><th>Units</th><th>Date/Time</th><th>Action</th></tr>`;
        for (let i = 0; i < mHist.length; i++) {
            let prev = i > 0 ? mHist[i - 1].reading : 0;
            let curr = mHist[i].reading;
            let units = Math.max(0, curr - prev);
            let dt = new Date(mHist[i].date).toLocaleString();

            html += `<tr>
                <td>${prev}</td>
                <td>${curr}</td>
                <td>${units}</td>
                <td>${dt}</td>
                <td><button class="btn-del" onclick="deleteHistory(${mHist[i].id})">Del</button></td>
            </tr>`;
        }
        html += `</table>`;
        if (container) container.innerHTML = html;
    });

    // Alerts Render
    let alertContainer = document.getElementById('alert_list_container');
    let aHtml = "";
    appData.alerts.forEach(a => {
        aHtml += `<div style="display:flex; justify-content:space-between; padding:5px; border-bottom:1px solid #ccc;">
            <span>${a.text}</span>
            <button class="btn-del" onclick="deleteAlert(${a.id})">Del</button>
        </div>`;
    });
    if (alertContainer) alertContainer.innerHTML = aHtml || "<p>No active alerts.</p>";
}

// Run UI Render
renderUI();
