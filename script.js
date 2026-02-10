// Global Variables
let invoiceData = {
    items: [],
    currentUnit: 'mm',
    lastItemId: 0,
    invoiceNo: 'GL-' + new Date().getFullYear() + '-' + (Math.floor(Math.random() * 9000) + 1000),
    charges: {
        cutting: 15,
        drilling: 25,
        polishing: 30,
        tempering: 45,
        lamination: 60,
        taper: 40,
        transport: 500,
        packing: 300,
        loading: 200,
        installation: 1000
    },
    taxes: {
        sgst: 9,
        cgst: 9,
        igst: 18
    }
};

// Initialize on load
document.addEventListener('DOMContentLoaded', function() {
    // Set current date
    const today = new Date();
    document.getElementById('currentDate').textContent = formatDate(today);
    document.getElementById('invoiceNo').textContent = invoiceData.invoiceNo;
    document.getElementById('orderDate').valueAsDate = today;
    document.getElementById('dueDate').valueAsDate = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000);
    document.getElementById('dispatchDate').valueAsDate = today;
    document.getElementById('estimatedDelivery').valueAsDate = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);
    
    // Set default charge values
    Object.keys(invoiceData.charges).forEach(key => {
        const element = document.getElementById(key + 'Charge');
        if (element) element.value = invoiceData.charges[key];
    });
    
    // Set default tax values
    document.getElementById('sgstRate').value = invoiceData.taxes.sgst;
    document.getElementById('cgstRate').value = invoiceData.taxes.cgst;
    document.getElementById('igstRate').value = invoiceData.taxes.igst;
    
    // Add first sample item
    addGlassItem();
});

// Format date function
function formatDate(date) {
    return date.toLocaleDateString('en-IN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
    });
}

// Set measurement unit
function setUnit(unit) {
    invoiceData.currentUnit = unit;
    
    // Update button states
    ['mm', 'inch', 'feet'].forEach(u => {
        const btn = document.getElementById('unit' + u.toUpperCase());
        btn.classList.toggle('active', u === unit);
    });
    
    // Convert existing items
    invoiceData.items.forEach(item => {
        if (item.unit !== unit) {
            convertItemDimensions(item.id, unit);
        }
    });
    
    // Update display
    updateAllItems();
}

// Convert dimensions between units
function convertDimensions(value, fromUnit, toUnit) {
    const conversion = {
        'mm': { 'inch': 0.0393701, 'feet': 0.00328084 },
        'inch': { 'mm': 25.4, 'feet': 0.0833333 },
        'feet': { 'mm': 304.8, 'inch': 12 }
    };
    
    if (fromUnit === toUnit) return value;
    return value * conversion[fromUnit][toUnit];
}

// Convert item dimensions
function convertItemDimensions(itemId, toUnit) {
    const item = invoiceData.items.find(i => i.id === itemId);
    if (!item) return;
    
    const fromUnit = item.unit || invoiceData.currentUnit;
    
    // Convert dimensions
    item.width = convertDimensions(item.width, fromUnit, toUnit);
    item.height = convertDimensions(item.height, fromUnit, toUnit);
    item.taperWidth = item.taperWidth ? convertDimensions(item.taperWidth, fromUnit, toUnit) : 0;
    item.taperHeight = item.taperHeight ? convertDimensions(item.taperHeight, fromUnit, toUnit) : 0;
    item.paimaish = item.paimaish ? convertDimensions(item.paimaish, fromUnit, toUnit) : 0;
    item.extraMM = item.extraMM ? convertDimensions(item.extraMM, fromUnit, toUnit) : 0;
    
    item.unit = toUnit;
}

// Add new glass item
function addGlassItem() {
    const itemId = ++invoiceData.lastItemId;
    
    const newItem = {
        id: itemId,
        description: 'Clear Float Glass',
        glassType: 'clear',
        thickness: '6',
        width: 1000,
        height: 1500,
        unit: invoiceData.currentUnit,
        isTaper: false,
        taperWidth: 0,
        taperHeight: 0,
        fabrication: [],
        paimaish: 5, // 5mm by default
        extraMM: 3, // 3mm by default
        qty: 1,
        rate: 80,
        area: 0,
        amount: 0
    };
    
    invoiceData.items.push(newItem);
    renderGlassItem(newItem);
    calculateItem(itemId);
}

// Render glass item row
function renderGlassItem(item) {
    const row = document.createElement('tr');
    row.className = 'glass-item-row';
    row.id = `item-${item.id}`;
    
    // Get unit symbol
    const unitSymbol = getUnitSymbol(item.unit);
    
    row.innerHTML = `
        <td>${item.id}</td>
        <td>
            <input type="text" class="form-control form-control-sm" value="${item.description}" 
                   onchange="updateItemField(${item.id}, 'description', this.value)">
        </td>
        <td>
            <select class="form-select form-select-sm" onchange="updateItemField(${item.id}, 'glassType', this.value)">
                <option value="clear" ${item.glassType === 'clear' ? 'selected' : ''}>Clear</option>
                <option value="tinted" ${item.glassType === 'tinted' ? 'selected' : ''}>Tinted</option>
                <option value="tempered" ${item.glassType === 'tempered' ? 'selected' : ''}>Tempered</option>
                <option value="laminated" ${item.glassType === 'laminated' ? 'selected' : ''}>Laminated</option>
                <option value="reflective" ${item.glassType === 'reflective' ? 'selected' : ''}>Reflective</option>
                <option value="patterned" ${item.glassType === 'patterned' ? 'selected' : ''}>Patterned</option>
            </select>
        </td>
        <td>
            <select class="form-select form-select-sm" onchange="updateItemField(${item.id}, 'thickness', this.value)">
                <option value="4" ${item.thickness === '4' ? 'selected' : ''}>4mm</option>
                <option value="5" ${item.thickness === '5' ? 'selected' : ''}>5mm</option>
                <option value="6" ${item.thickness === '6' ? 'selected' : ''}>6mm</option>
                <option value="8" ${item.thickness === '8' ? 'selected' : ''}>8mm</option>
                <option value="10" ${item.thickness === '10' ? 'selected' : ''}>10mm</option>
                <option value="12" ${item.thickness === '12' ? 'selected' : ''}>12mm</option>
                <option value="15" ${item.thickness === '15' ? 'selected' : ''}>15mm</option>
            </select>
        </td>
        <td>
            <div class="d-flex gap-2">
                <input type="number" class="form-control form-control-sm dimension-input" 
                       value="${item.width.toFixed(2)}" step="0.01" min="1"
                       onchange="updateItemField(${item.id}, 'width', parseFloat(this.value))">
                <span class="align-self-center">×</span>
                <input type="number" class="form-control form-control-sm dimension-input" 
                       value="${item.height.toFixed(2)}" step="0.01" min="1"
                       onchange="updateItemField(${item.id}, 'height', parseFloat(this.value))">
                <span class="align-self-center">${unitSymbol}</span>
            </div>
        </td>
        <td>
            <div class="form-check">
                <input class="form-check-input" type="checkbox" ${item.isTaper ? 'checked' : ''} 
                       onchange="toggleTaper(${item.id}, this.checked)">
                <label class="form-check-label">Taper</label>
            </div>
            ${item.isTaper ? `
                <div class="mt-2">
                    <small>Taper Size:</small>
                    <input type="number" class="form-control form-control-sm mt-1" 
                           value="${item.taperWidth}" placeholder="Width"
                           onchange="updateItemField(${item.id}, 'taperWidth', parseFloat(this.value))">
                    <input type="number" class="form-control form-control-sm mt-1" 
                           value="${item.taperHeight}" placeholder="Height"
                           onchange="updateItemField(${item.id}, 'taperHeight', parseFloat(this.value))">
                </div>
            ` : ''}
        </td>
        <td>
            <div class="fab-options">
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" value="cutting" 
                           ${item.fabrication.includes('cutting') ? 'checked' : ''}
                           onchange="toggleFabrication(${item.id}, 'cutting', this.checked)">
                    <label class="form-check-label">Cut</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" value="drill" 
                           ${item.fabrication.includes('drill') ? 'checked' : ''}
                           onchange="toggleFabrication(${item.id}, 'drill', this.checked)">
                    <label class="form-check-label">Drill</label>
                </div>
                <div class="form-check form-check-inline">
                    <input class="form-check-input" type="checkbox" value="polish" 
                           ${item.fabrication.includes('polish') ? 'checked' : ''}
                           onchange="toggleFabrication(${item.id}, 'polish', this.checked)">
                    <label class="form-check-label">Polish</label>
                </div>
            </div>
        </td>
        <td>
            <div class="input-group input-group-sm">
                <input type="number" class="form-control" value="${item.paimaish}" step="0.01" min="0"
                       onchange="updateItemField(${item.id}, 'paimaish', parseFloat(this.value))">
                <span class="input-group-text">${unitSymbol}</span>
            </div>
            <small class="text-muted">Paimaish</small>
        </td>
        <td>
            <div class="input-group input-group-sm">
                <input type="number" class="form-control" value="${item.extraMM}" step="0.01" min="0"
                       onchange="updateItemField(${item.id}, 'extraMM', parseFloat(this.value))">
                <span class="input-group-text">${unitSymbol}</span>
            </div>
            <small class="text-muted">+MM</small>
        </td>
        <td class="item-area">${item.area.toFixed(2)}</td>
        <td>
            <div class="input-group input-group-sm">
                <span class="input-group-text">₹</span>
                <input type="number" class="form-control" value="${item.rate}" step="0.01" min="0"
                       onchange="updateItemField(${item.id}, 'rate', parseFloat(this.value))">
            </div>
        </td>
        <td class="item-amount fw-bold">₹${item.amount.toFixed(2)}</td>
        <td>
            <button class="btn btn-danger btn-sm" onclick="removeItem(${item.id})">
                <i class="fas fa-trash"></i>
            </button>
        </td>
    `;
    
    document.getElementById('glassItemsTable').appendChild(row);
}

// Get unit symbol
function getUnitSymbol(unit) {
    switch(unit) {
        case 'mm': return 'mm';
        case 'inch': return '"';
        case 'feet': return "'";
        default: return 'mm';
    }
}

// Update item field
function updateItemField(itemId, field, value) {
    const item = invoiceData.items.find(i => i.id === itemId);
    if (!item) return;
    
    item[field] = value;
    calculateItem(itemId);
}

// Toggle taper
function toggleTaper(itemId, isTaper) {
    const item = invoiceData.items.find(i => i.id === itemId);
    if (!item) return;
    
    item.isTaper = isTaper;
    if (!isTaper) {
        item.taperWidth = 0;
        item.taperHeight = 0;
    }
    
    // Re-render the row to show/hide taper inputs
    const row = document.getElementById(`item-${itemId}`);
    if (row) row.remove();
    renderGlassItem(item);
    calculateItem(itemId);
}

// Toggle fabrication
function toggleFabrication(itemId, fabType, isChecked) {
    const item = invoiceData.items.find(i => i.id === itemId);
    if (!item) return;
    
    if (isChecked) {
        if (!item.fabrication.includes(fabType)) {
            item.fabrication.push(fabType);
        }
    } else {
        item.fabrication = item.fabrication.filter(f => f !== fabType);
    }
    
    calculateItem(itemId);
}

// Calculate item area and amount
function calculateItem(itemId) {
    const item = invoiceData.items.find(i => i.id === itemId);
    if (!item) return;
    
    // Convert dimensions to mm for calculation
    let widthMM = item.width;
    let heightMM = item.height;
    
    if (item.unit !== 'mm') {
        widthMM = convertDimensions(item.width, item.unit, 'mm');
        heightMM = convertDimensions(item.height, item.unit, 'mm');
    }
    
    // Add paimaish and extra MM to actual dimensions
    const actualWidth = widthMM + (item.paimaish || 0) + (item.extraMM || 0);
    const actualHeight = heightMM + (item.paimaish || 0) + (item.extraMM || 0);
    
    // Calculate area in square feet
    const areaSqFt = (actualWidth * actualHeight) / 92903.04; // 1 sq.ft = 92903.04 sq.mm
    
    // Calculate amount
    item.area = areaSqFt * item.qty;
    item.amount = item.area * item.rate;
    
    // Update display
    const row = document.getElementById(`item-${itemId}`);
    if (row) {
        row.querySelector('.item-area').textContent = item.area.toFixed(2);
        row.querySelector('.item-amount').textContent = '₹' + item.amount.toFixed(2);
    }
    
    calculateAllCharges();
}

// Remove item
function removeItem(itemId) {
    if (!confirm('Are you sure you want to remove this item?')) return;
    
    invoiceData.items = invoiceData.items.filter(item => item.id !== itemId);
    const row = document.getElementById(`item-${itemId}`);
    if (row) row.remove();
    
    calculateAllCharges();
}

// Update all items display
function updateAllItems() {
    // Clear table
    const table = document.getElementById('glassItemsTable');
    while (table.firstChild) {
        table.removeChild(table.firstChild);
    }
    
    // Re-render all items
    invoiceData.items.forEach(item => renderGlassItem(item));
}

// Calculate all charges
function calculateAllCharges() {
    let totalArea = 0;
    let glassCost = 0;
    let fabCharges = 0;
    let otherCharges = 0;
    
    // Calculate from items
    invoiceData.items.forEach(item => {
        totalArea += item.area;
        glassCost += item.amount;
        
        // Calculate fabrication charges
        item.fabrication.forEach(fab => {
            switch(fab) {
                case 'cutting':
                    fabCharges += item.area * invoiceData.charges.cutting;
                    break;
                case 'drill':
                    fabCharges += 4 * invoiceData.charges.drilling; // Assuming 4 holes
                    break;
                case 'polish':
                    // Calculate perimeter in feet
                    const perimeterFt = (2 * (item.width + item.height)) / 304.8; // Convert mm to feet
                    fabCharges += perimeterFt * invoiceData.charges.polishing;
                    break;
            }
        });
        
        // Taper charges
        if (item.isTaper) {
            const taperPerimeter = (2 * (item.taperWidth + item.taperHeight)) / 304.8;
            fabCharges += taperPerimeter * invoiceData.charges.taper;
        }
        
        // Tempering/Lamination based on glass type
        if (item.glassType === 'tempered') {
            fabCharges += item.area * invoiceData.charges.tempering;
        } else if (item.glassType === 'laminated') {
            fabCharges += item.area * invoiceData.charges.lamination;
        }
    });
    
    // Calculate other charges
    otherCharges = Object.keys(invoiceData.charges).reduce((sum, key) => {
        if (['transport', 'packing', 'loading', 'installation'].includes(key)) {
            return sum + invoiceData.charges[key];
        }
        return sum;
    }, 0);
    
    // Update charge values from inputs
    updateChargesFromInputs();
    
    // Calculate subtotal
    const subTotal = glassCost + fabCharges + otherCharges;
    
    // Calculate tax
    const taxRate = invoiceData.taxes.sgst + invoiceData.taxes.cgst;
    const taxAmount = (subTotal * taxRate) / 100;
    
    // Calculate grand total
    const grandTotal = subTotal + taxAmount;
    
    // Update display
    document.getElementById('totalArea').value = totalArea.toFixed(2);
    document.getElementById('glassCost').value = glassCost.toFixed(2);
    document.getElementById('fabCharges').value = fabCharges.toFixed(2);
    document.getElementById('otherCharges').value = otherCharges.toFixed(2);
    document.getElementById('subTotal').value = subTotal.toFixed(2);
    document.getElementById('taxAmount').value = taxAmount.toFixed(2);
    document.getElementById('grandTotal').value = grandTotal.toFixed(2);
    
    return { totalArea, glassCost, fabCharges, otherCharges, subTotal, taxAmount, grandTotal };
}

// Update charges from input fields
function updateChargesFromInputs() {
    // Update fabrication charges
    invoiceData.charges.cutting = parseFloat(document.getElementById('cuttingCharge').value) || 0;
    invoiceData.charges.drilling = parseFloat(document.getElementById('drillingCharge').value) || 0;
    invoiceData.charges.polishing = parseFloat(document.getElementById('polishingCharge').value) || 0;
    invoiceData.charges.tempering = parseFloat(document.getElementById('temperingCharge').value) || 0;
    invoiceData.charges.lamination = parseFloat(document.getElementById('laminationCharge').value) || 0;
    invoiceData.charges.taper = parseFloat(document.getElementById('taperCharge').value) || 0;
    
    // Update other charges
    invoiceData.charges.transport = parseFloat(document.getElementById('transportCharge').value) || 0;
    invoiceData.charges.packing = parseFloat(document.getElementById('packingCharge').value) || 0;
    invoiceData.charges.loading = parseFloat(document.getElementById('loadingCharge').value) || 0;
    invoiceData.charges.installation = parseFloat(document.getElementById('installationCharge').value) || 0;
    
    // Update taxes
    invoiceData.taxes.sgst = parseFloat(document.getElementById('sgstRate').value) || 0;
    invoiceData.taxes.cgst = parseFloat(document.getElementById('cgstRate').value) || 0;
    invoiceData.taxes.igst = parseFloat(document.getElementById('igstRate').value) || 0;
}

// Generate PDF
function generatePDF() {
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF('p', 'mm', 'a4');
    
    // Add content to PDF
    // ... (PDF generation code similar to previous example but with new fields)
    
    doc.save(`Glass_Invoice_${invoiceData.invoiceNo}.pdf`);
}

// Print invoice
function printInvoice() {
    window.print();
}

// Save invoice
function saveInvoice() {
    const invoice = {
        ...invoiceData,
        customer: {
            name: document.getElementById('companyName').value,
            contact: document.getElementById('contactPerson').value,
            address: document.getElementById('customerAddress').value,
            mobile: document.getElementById('customerMobile').value,
            gst: document.getElementById('customerGST').value,
            email: document.getElementById('customerEmail').value
        },
        order: {
            orderNo: document.getElementById('orderNo').value,
            orderDate: document.getElementById('orderDate').value,
            poNumber: document.getElementById('poNumber').value,
            dueDate: document.getElementById('dueDate').value,
            project: document.getElementById('projectName').value
        },
        dispatch: {
            date: document.getElementById('dispatchDate').value,
            vehicle: document.getElementById('vehicleType').value,
            vehicleNo: document.getElementById('vehicleNo').value,
            driver: document.getElementById('driverName').value,
            driverContact: document.getElementById('driverContact').value,
            estimatedDelivery: document.getElementById('estimatedDelivery').value,
            address: document.getElementById('deliveryAddress').value,
            instructions: document.getElementById('deliveryInstructions').value,
            status: document.getElementById('dispatchStatus').value
        },
        calculations: calculateAllCharges(),
        timestamp: new Date().toISOString()
    };
    
    // Save to localStorage
    localStorage.setItem(`invoice_${invoiceData.invoiceNo}`, JSON.stringify(invoice));
    
    // Add to invoices list
    let invoices = JSON.parse(localStorage.getItem('invoices') || '[]');
    invoices.push({
        id: invoiceData.invoiceNo,
        date: new Date().toISOString(),
        customer: invoice.customer.name,
        total: invoice.calculations.grandTotal,
        items: invoice.items.length
    });
    localStorage.setItem('invoices', JSON.stringify(invoices));
    
    alert(`Invoice ${invoiceData.invoiceNo} saved successfully!`);
}

// Generate tracking ID
function generateTracking() {
    const trackingId = 'TRK-' + new Date().getFullYear() + 
                      (Math.floor(Math.random() * 90000) + 10000);
    document.getElementById('trackingId').textContent = trackingId;
    
    // Save tracking info
    const trackingData = {
        invoiceNo: invoiceData.invoiceNo,
        trackingId: trackingId,
        status: document.getElementById('dispatchStatus').value,
        date: new Date().toISOString()
    };
    
    localStorage.setItem(`tracking_${trackingId}`, JSON.stringify(trackingData));
    
    alert(`Tracking ID Generated: ${trackingId}`);
}

// Track shipment
function trackShipment() {
    const trackingId = document.getElementById('trackingId').textContent;
    if (trackingId.startsWith('TRK-')) {
        alert(`Tracking ID: ${trackingId}\nStatus: ${document.getElementById('dispatchStatus').value}`);
    } else {
        alert('Please generate a tracking ID first.');
    }
}

// Send email (simulated)
function sendEmail() {
    const email = document.getElementById('customerEmail').value;
    if (email) {
        alert(`Invoice will be sent to: ${email}\n\nThis is a simulation. In real implementation, connect to email API.`);
    } else {
        alert('Please enter customer email address.');
    }
}

// Reset form
function resetForm() {
    if (confirm('Are you sure you want to reset all data? This cannot be undone.')) {
        invoiceData = {
            items: [],
            currentUnit: 'mm',
            lastItemId: 0,
            invoiceNo: 'GL-' + new Date().getFullYear() + '-' + (Math.floor(Math.random() * 9000) + 1000),
            charges: {
                cutting: 15,
                drilling: 25,
                polishing: 30,
                tempering: 45,
                lamination: 60,
                taper: 40,
                transport: 500,
                packing: 300,
                loading: 200,
                installation: 1000
            },
            taxes: {
                sgst: 9,
                cgst: 9,
                igst: 18
            }
        };
        
        // Reset all inputs
        document.getElementById('glassItemsTable').innerHTML = '';
        document.getElementById('companyName').value = '';
        document.getElementById('contactPerson').value = '';
        document.getElementById('customerAddress').value = '';
        document.getElementById('customerMobile').value = '';
        document.getElementById('customerGST').value = '';
        document.getElementById('customerEmail').value = '';
        document.getElementById('orderNo').value = 'ORD-GL-' + new Date().getFullYear() + '-' + (Math.floor(Math.random() * 900) + 100);
        document.getElementById('invoiceNo').textContent = invoiceData.invoiceNo;
        
        // Reset calculations
        document.getElementById('totalArea').value = '0.00';
        document.getElementById('glassCost').value = '0.00';
        document.getElementById('fabCharges').value = '0.00';
        document.getElementById('otherCharges').value = '0.00';
        document.getElementById('subTotal').value = '0.00';
        document.getElementById('taxAmount').value = '0.00';
        document.getElementById('grandTotal').value = '0.00';
        
        // Add first item
        addGlassItem();
    }
}
