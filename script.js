// Data Structure
let appData = JSON.parse(localStorage.getItem('elec_app_data')) || {
    fixedBudget: 30000,
    meterNames: { m1: "Meter 1", m2: "Meter 2", m3: "Meter 3", m4: "Meter 4" },
    deposits: { m1: 0, m2: 0, m3: 0, m4: 0 },
    limits: {
        m1: { rate: 35 },
        m2: { rate: 35 },
        m3: { rate: 35 },
        m4: { rate: 100 }
    },
    history: []
};

function saveData() {
    localStorage.setItem('elec_app_data', JSON.stringify(appData));
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

function openModal(id) {
    document.getElementById(id).style.display = 'flex';
}

function closeModal(id) {
    document.getElementById(id).style.display = 'none';
}

function saveBudget() {
    appData.fixedBudget = parseFloat(document.getElementById('budgetInput').value) || 0;
    closeModal('budgetModal');
    saveData();
}

function saveMeterNames() {
    appData.meterNames.m1 = document.getElementById('name_m1').value || "Meter 1";
    appData.meterNames.m2 = document.getElementById('name_m2').value || "Meter 2";
    appData.meterNames.m3 = document.getElementById('name_m3').value || "Meter 3";
    appData.meterNames.m4 = document.getElementById('name_m4').value || "Meter 4";
    closeModal('meterNamesModal');
    saveData();
}

function saveLimits() {
    let m = document.getElementById('limitMeterSelect').value;
    appData.limits[m].rate = parseFloat(document.getElementById('unitRate').value) || 0;
    closeModal('unitRatesModal');
    saveData();
}

function saveReading() {
    let m = document.getElementById('entryMeterSelect').value;
    let val = parseFloat(document.getElementById('newReadingInput').value) || 0;
    let fileInput = document.getElementById('billImgInput');

    let record = {
        meter: m,
        reading: val,
        date: new Date().toLocaleString(),
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

function saveDeposit() {
    let m = document.getElementById('depMeterSelect').value;
    let amt = parseFloat(document.getElementById('depAmount').value) || 0;
    appData.deposits[m] += amt;
    saveData();
}

function calcGas() {
    let diff = parseFloat(document.getElementById('hm3Diff').value) || 0;
    let press = parseFloat(document.getElementById('pressFactor').value) || 1;
    let gcv = parseFloat(document.getElementById('gcvRate').value) || 1;
    let ans = (diff * press * gcv) / 281.7385;
    document.getElementById('gasResult').innerText = ans.toFixed(4);
}

function downloadBackup() {
    let dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(appData));
    let dlAnchorElem = document.createElement('a');
    dlAnchorElem.setAttribute("href", dataStr);
    dlAnchorElem.setAttribute("download", "electrical_bill_backup.json");
    dlAnchorElem.click();
}

function resetData() {
    if(confirm("Are you sure to reset all data?")) {
        localStorage.removeItem('elec_app_data');
        location.reload();
    }
}

function renderUI() {
    document.getElementById('lbl_m1_dep').innerText = appData.meterNames.m1;
    document.getElementById('lbl_m2_dep').innerText = appData.meterNames.m2;
    document.getElementById('lbl_m3_dep').innerText = appData.meterNames.m3;
    document.getElementById('lbl_m4_dep').innerText = appData.meterNames.m4;

    document.getElementById('dep_m1').innerText = appData.deposits.m1 + " RS";
    document.getElementById('dep_m2').innerText = appData.deposits.m2 + " RS";
    document.getElementById('dep_m3').innerText = appData.deposits.m3 + " RS";
    document.getElementById('dep_m4').innerText = appData.deposits.m4 + " RS";

    let histContainer = document.getElementById('historyTableContainer');
    histContainer.innerHTML = "";
    let table = `<table><tr><th>Meter Code</th><th>Reading</th><th>Date</th><th>Image</th></tr>`;
    
    appData.history.forEach(item => {
        let imgTag = item.img ? `<a href="${item.img}" target="_blank">View</a>` : 'No Image';
        table += `<tr>
            <td>${item.meter.toUpperCase()}</td>
            <td>${item.reading}</td>
            <td>${item.date}</td>
            <td>${imgTag}</td>
        </tr>`;
    });
    table += `</table>`;
    histContainer.innerHTML = table;
}

// Initial Execution
renderUI();
