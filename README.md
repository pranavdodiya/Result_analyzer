# Result Analyzer

A Rails API application that processes student test results and performs End-of-Day (EOD) and monthly calculations.

## Overview

- Receives test result data from a third-party service (MSM) in JSON format
- Stores all incoming test results
- Runs a scheduled EOD job daily at 6:00 PM to calculate:
  - **Daily Result Statistics** (per subject: low, high, count)
  - **Monthly Result Averages** (only on the Monday of the week containing the third Wednesday of the month)

## Tech Stack

- Ruby 2.6.6
- Rails 5.2.8.1 (API mode)
- SQLite3
- RSpec (testing)
- FactoryBot (test factories)
- Whenever (cron scheduling)
- SimpleCov (code coverage)

## Setup

```bash
git clone https://github.com/pranavdodiya/Result_analyzer.git
cd result_analyzer
bundle install
rails db:create db:migrate
```

## Running Tests

```bash
bundle exec rspec
```

Coverage report will be generated in `coverage/` directory.

## API Endpoints

### 1. Create Test Result (Data Ingestion)

```
POST /api/v1/test_results
```

**Request Body:**
```json
{
  "test_result": {
    "student_name": "Alice Smith",
    "subject": "Mathematics",
    "marks": 88.5,
    "timestamp": "2026-05-04T10:30:00Z"
  }
}
```

**Response (201):**
```json
{
  "id": 1,
  "student_name": "Alice Smith",
  "subject": "Mathematics",
  "marks": 88.5,
  "timestamp": "2026-05-04T10:30:00.000Z",
  "created_at": "...",
  "updated_at": "..."
}
```

### 2. List Test Results

```
GET /api/v1/test_results
GET /api/v1/test_results?subject=Mathematics
GET /api/v1/test_results?date=2026-05-04
```

### 3. List Daily Result Statistics

```
GET /api/v1/daily_result_statistics
GET /api/v1/daily_result_statistics?subject=Mathematics
GET /api/v1/daily_result_statistics?date=2026-05-04
```

### 4. List Monthly Result Averages

```
GET /api/v1/monthly_result_averages
GET /api/v1/monthly_result_averages?subject=Mathematics
```

## Scheduled Jobs

The EOD job runs daily at 6:00 PM (configured via `whenever` gem):

```bash
# Preview cron schedule
bundle exec whenever

# Write to crontab
bundle exec whenever --update-crontab
```

## Architecture & Design Decisions

### Models
- **TestResult** - Stores raw test results from MSM (student_name, subject, marks, timestamp)
- **DailyResultStatistic** - Aggregated daily stats per subject (daily_low, daily_high, result_count)
- **MonthlyResultAverage** - Monthly averages per subject (avg_daily_high, avg_daily_low, total_result_count)

### Services
- **DailyResultStatisticsCalculator** - Aggregates test results for a given day by subject. Computes min, max marks and count. Uses `find_or_initialize_by` to be idempotent.
- **MonthlyResultAveragesCalculator** - Runs only on the Monday of the week containing the third Wednesday of the month. Starts with last 5 days of daily statistics. If total result_count < 200, goes further back until >= 200.

### Jobs
- **EodProcessingJob** - Orchestrates daily and monthly calculations. Called by cron at 6:00 PM daily.

## Assumptions

1. **Marks range**: 0-100 (validated on ingestion)
2. **Timestamps**: Provided by MSM; used to determine which day a result belongs to
3. **Idempotency**: Running the EOD job multiple times for the same day updates existing records rather than creating duplicates
4. **Monthly calculation**: When going back beyond 5 days to reach 200 results, we stop as soon as the cumulative count reaches 200 (including the full day that pushes it over)
5. **Time zone**: The application uses the server's default time zone for day boundaries
6. **Subject uniqueness**: Daily stats and monthly averages are unique per subject+date/month combination
