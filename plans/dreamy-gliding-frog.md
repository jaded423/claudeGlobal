# Odoo Inventory Sheet Sync - Implementation Plan

## Goal
Create a Python script that syncs Odoo inventory data to a Google Sheet daily, with manual run option. The sheet will have two main tabs:
- **Current Inventory** - Bulk flower sold by LBS (organized by tier: AAA, AA, A, Smalls, etc.)
- **Label Ready** - Finished goods sold by Units (flower units, pre-rolls, concentrates)

## Key Decisions
- **Tier identification**: Extract from product name (e.g., "AAA - Blue Kush" → tier "AAA", strain "Blue Kush")
- **Sheet type**: LBS = Current Inventory, Units = Label Ready
- **Zero stock**: Remove row from sheet (don't keep zero-qty products)
- **Manual columns**: Preserve columns not sourced from Odoo (Nose Profile, quality scores, etc.)

---

## Phase 1: Odoo Data Exploration (First)

Before building the full sync, we need to understand the actual Odoo data structure.

### Step 1.1: Create exploration script
Create `/Users/j/projects/odooReports/inventory/explore_products.py` that queries:
1. `product.product` - Get all products with fields: name, default_code, list_price, categ_id, uom_id
2. `stock.quant` - Get current quantities with location info
3. Identify custom fields (x_studio_*) for THCa%, type, etc.

### Step 1.2: Run exploration and analyze
- Run script to dump product data
- Identify naming patterns for flower vs pre-rolls vs concentrates vs packaging
- Find which warehouse locations contain sellable inventory
- Check what custom fields exist for THCa%, I/H/S type

### Step 1.3: User review
- Share findings with user to confirm:
  - Which products to include/exclude
  - Which location(s) to query
  - Field mappings for THCa%, type, etc.

---

## Phase 2: Google Sheets API Setup

### Step 2.1: Enable Sheets API
- User enables Google Sheets API at: https://console.developers.google.com/apis/api/sheets.googleapis.com/overview?project=664420379329

### Step 2.2: Create or identify target sheet
Option A: Update the existing "Test | Inventory Sheet" (ID: `1WLZ5gQkg10N-W2QwO7BTJI8KAl5QQMizVjL7IBNhO30`)
Option B: Create a new sheet for the live data

### Step 2.3: OAuth token for Sheets
- Generate token with `spreadsheets` scope (read/write)
- Store as `inventory/sheets_token.json`

---

## Phase 3: Build Sync Script

### Step 3.1: Create main script
Create `/Users/j/projects/odooReports/inventory/inventory_sync.py`

**Core logic:**
```
1. Connect to Odoo
2. Query products + stock.quant for current quantities
3. Filter to relevant products (based on Phase 1 findings)
4. Parse product names → extract tier + strain name
5. Split into LBS products vs Units products
6. Read existing sheet data
7. Update Odoo-sourced columns, preserve manual columns
8. Remove rows for products with qty = 0
9. Write updated data back to sheet
10. Log changes made
```

**Key functions:**
- `parse_product_name(name)` → returns {tier, strain, product_type}
- `get_odoo_inventory()` → returns list of products with qty
- `sync_sheet(sheet_name, products)` → update Google Sheet
- `preserve_manual_columns(old_row, new_row, manual_cols)` → merge data

### Step 3.2: Create run.sh wrapper
Create `/Users/j/projects/odooReports/inventory/run.sh`
- Sets up environment
- Runs Python script
- Logs output

### Step 3.3: Create requirements.txt
Dependencies: google-api-python-client, google-auth-oauthlib, pandas, etc.

---

## Phase 4: Column Mapping

Based on the xlsx analysis, here's the target structure:

### Current Inventory (LBS)
| Column | Source | Notes |
|--------|--------|-------|
| Current Strains | Odoo product.name (parsed) | Tier header rows + strain names |
| Available LBS | Odoo stock.quant.available_quantity | |
| List Price | Odoo product.list_price | |
| I/H/S | Odoo custom field OR manual | TBD based on exploration |
| THCa% | Odoo custom field OR manual | TBD based on exploration |
| Nose Profile | Manual | Preserve from existing sheet |
| Color Profile | Manual | Preserve from existing sheet |
| Quality scores | Manual | Preserve from existing sheet |

### Label Ready (Units)
| Column | Source | Notes |
|--------|--------|-------|
| Product Name | Odoo product.name | |
| Available Units | Odoo stock.quant.available_quantity | |
| List Price | Odoo product.list_price | |
| I/H/S | Odoo custom field OR manual | |
| THCa% | Odoo custom field OR manual | |
| Nose Profile | Manual | |

---

## Phase 5: Scheduling

### Step 5.1: Add to cron
Since other odooReports run on PC/WSL, this will too:
```bash
# Daily at 6:00 AM (before business hours)
0 6 * * * /home/joshua/projects/odooReports/inventory/run.sh >> /home/joshua/projects/odooReports/inventory/logs/cron.log 2>&1
```

### Step 5.2: Manual run option
Script can be run anytime via:
```bash
bash ~/projects/odooReports/inventory/run.sh
```

---

## File Structure

```
odooReports/
└── inventory/
    ├── inventory_sync.py      # Main sync script
    ├── explore_products.py    # One-time exploration script
    ├── run.sh                 # Execution wrapper
    ├── requirements.txt       # Dependencies
    ├── sheets_token.json      # Google Sheets OAuth token (gitignored)
    └── logs/
        └── cron.log           # Execution logs
```

---

## Verification Plan

1. **Phase 1 verification**: Run explore_products.py, review output with user
2. **Phase 2 verification**: Confirm Sheets API is enabled, test read/write to sheet
3. **Phase 3 verification**:
   - Run sync manually
   - Verify Current Inventory tab updates correctly
   - Verify Label Ready tab updates correctly
   - Verify manual columns are preserved
   - Verify zero-stock products are removed
4. **Phase 5 verification**: Add to cron, wait for next scheduled run, check logs

---

## Open Questions (to resolve in Phase 1)

1. What custom fields exist in Odoo for THCa%, I/H/S type?
2. Which warehouse location IDs contain sellable inventory?
3. How are pre-rolls vs flower vs concentrates distinguished in product names?
4. Should we update the existing Test sheet or create a new one?
