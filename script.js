let appData = JSON.parse(localStorage.getItem('final_bill_app_data')) || {
    meterNames: { m1: "Meter 1", m2: "Meter 2", m3: "Meter 3", gas: "Gas Meter" },
    deposits: { m1: 0, m2: 0, m3: 0, gas: 0 },
    dueDates: { m1: "", m2: "", m3: "", gas: "" },
    fixedBudget: 30000,
    analysisPayments: [],
    alerts: [],
    history: []
};

function saveData() {
    localStorage.setItem('final_bill_app_data', JSON.stringify(appData));
    renderUI();
}

function toggleSidebar() { document.getElementById('sidebar').classList.toggle('active'); }
function openModal(id) { document.getElementById(id).style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }

function switchTab(tabId) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    document.getElementById(tabId).classList.add('active');
}

function saveMeterNames() {
    appData.meterNames.m1 = document.getElementById('name_m1').value || "Meter 1";
    appData.meterNames.m2 = document.getElementById('name_m2').value || "Meter 2";
    appData.meterNames.m3 = document.getElementById('name_m3').value || "Meter 3";
    appData.meterNames.gas = document.getElementById('name_m4').value || "Gas Meter";
    closeModal('meterNamesModal');
    saveData();
}

// Deposit Analysis Logic
function saveAnalysisDeposit() {
    let m = document.getElementById('an_meter_select').value;
    let amt = parseFloat(document.getElementById('an_bill_amount').value) || 0;
    let dt = document.getElementById('an_pay_date').value || new Date().toISOString().split('T')[0];
    let src = document.getElementById('an_pay_source').value;

    appData.analysisPayments.push({ id: Date.now(), meter: m, amount: amt, date: dt, source: src });
    appData.deposits[m] += amt;
    saveData();
}

function deletePayment(id) {
    appData.analysisPayments = appData.analysisPayments.filter(p => p.id !== id);
    saveData();
}

function calcCombinedTotal() {
    let ghar = appData.analysisPayments.filter(p => p.source === 'Ghar').reduce((a, b) => a + b.amount, 0);
    let bahir = appData.analysisPayments.filter(p => p.source === 'Bahir').reduce((a, b) => a + b.amount, 0);
    alert(`گھر والا بل: ${ghar} RS\nباہر والا بل: ${bahir} RS\nکل گرینڈ ٹوٹل: ${ghar + bahir} RS`);
}

function saveDueDate() {
    let m = document.getElementById('due_meter_select').value;
    let dt = document.getElementById('due_date_input').value;
    appData.dueDates[m] = dt;
    saveData();
}

// Speech & Voice Alert Mechanism
function triggerVoiceAlert(text) {
    if ('speechSynthesis' in window) {
        let speech = new SpeechSynthesisUtterance(text);
        speech.lang = 'ur-PK';
        speech.rate = 0.9;
        window.speechSynthesis.speak(speech);
    }
    if (navigator.vibrate) {
        navigator.vibrate([500, 200, 500]);
    }
}

function saveAlert() {
    let txt = document.getElementById('alert_text').value;
    let timeVal = document.getElementById('alert_time_input').value;
    if (txt) {
        appData.alerts.push({ id: Date.now(), text: txt, time: timeVal });
        document.getElementById('alert_text').value = "";
        saveData();
    }
}

function deleteAlert(id) {
    appData.alerts = appData.alerts.filter(a => a.id !== id);
    saveData();
}

function testAlert(text) {
    triggerVoiceAlert("الرٹ ٹیسٹ: " + text);
}

// Check Timers
setInterval(() => {
    let now = new Date().getTime();
    appData.alerts.forEach(a => {
        if (a.time && new Date(a.time).getTime() <= now && !a.triggered) {
            triggerVoiceAlert(a.text);
            a.triggered = true;
            saveData();
        }
    });
}, 10000);

function confirmResetAllData() {
    if (confirm("کیا آپ واقعی تمام ڈیٹا ڈیلیٹ کرنا چاہتے ہیں؟")) {
        localStorage.removeItem('final_bill_app_data');
        location.reload();
    }
}

function renderUI() {
    // Meter Labels
    document.getElementById('dash_m1').innerText = appData.meterNames.m1;
    document.getElementById('dash_m2').innerText = appData.meterNames.m2;
    document.getElementById('dash_m3').innerText = appData.meterNames.m3;
    document.getElementById('dash_m4').innerText = appData.meterNames.gas;

    document.getElementById('dep_m1').innerText = appData.deposits.m1 + " RS";
    document.getElementById('dep_m2').innerText = appData.deposits.m2 + " RS";
    document.getElementById('dep_m3').innerText = appData.deposits.m3 + " RS";
    document.getElementById('dep_m4').innerText = appData.deposits.gas + " RS";

    // Payment History Table
    let tableContainer = document.getElementById('analysis_table_container');
    let pHtml = `<table><tr><th>تاریخ</th><th>میٹر</th><th>رقم</th><th>ذریعہ</th><th>ایکشن</th></tr>`;
    let gharTot = 0, bahirTot = 0;

    appData.analysisPayments.forEach(p => {
        if (p.source === 'Ghar') gharTot += p.amount;
        if (p.source === 'Bahir') bahirTot += p.amount;
        pHtml += `<tr>
            <td>${p.date}</td>
            <td>${appData.meterNames[p.meter] || p.meter}</td>
            <td>${p.amount} RS</td>
            <td>${p.source}</td>
            <td><button class="btn-del" onclick="deletePayment(${p.id})">Del</button></td>
        </tr>`;
    });
    pHtml += `</table>`;
    tableContainer.innerHTML = pHtml;

    document.getElementById('tot_ghar_bill').innerText = gharTot + " RS";
    document.getElementById('tot_bahir_bill').innerText = bahirTot + " RS";

    // Due Dates Display
    let dueBox = document.getElementById('due_dates_display_box');
    dueBox.innerHTML = `
        <p><b>${appData.meterNames.m1}:</b> ${appData.dueDates.m1 || 'Not set'}</p>
        <p><b>${appData.meterNames.m2}:</b> ${appData.dueDates.m2 || 'Not set'}</p>
        <p><b>${appData.meterNames.m3}:</b> ${appData.dueDates.m3 || 'Not set'}</p>
        <p><b>${appData.meterNames.gas}:</b> ${appData.dueDates.gas || 'Not set'}</p>
    `;

    // Active Alerts List Display
    let alertBox = document.getElementById('alerts_list_box');
    let aHtml = "";
    appData.alerts.forEach(a => {
        aHtml += `<div style="display:flex; justify-content:space-between; align-items:center; padding:8px; border-bottom:1px solid #ccc;">
            <span><b>${a.text}</b> <br><small>${a.time || 'No time set'}</small></span>
            <div>
                <button class="btn-test" onclick="testAlert('${a.text}')">Test Voice</button>
                <button class="btn-del" onclick="deleteAlert(${a.id})">Del</button>
            </div>
        </div>`;
    });
    alertBox.innerHTML = aHtml || "<p>کوئی الرٹ موجود نہیں ہے۔</p>";
}

renderUI();
