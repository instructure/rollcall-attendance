/*
 * Copyright (C) 2016 - present Instructure, Inc.
 *
 * This file is part of Rollcall.
 *
 * Rollcall is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Rollcall is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

var AttendanceChart = React.createClass({
  displayName: 'AttendanceChart',
  propTypes: {
    chartData: React.PropTypes.shape({
      present_statuses: React.PropTypes.number.isRequired,
      absent_statuses: React.PropTypes.number.isRequired,
      late_statuses: React.PropTypes.number.isRequired
    }).isRequired
  },
  render: function() {
    return (
      <div className="student-chart">
        <canvas ref="chart" />
        <div className="student-chart-title">
          <div className="student-chart-title-header">{this.totalDaysMarked()}</div>
          <div className="student-chart-title-body">Days Total</div>
        </div>
      </div>
    );
  },
  componentDidMount: function() {
    new Chart(this.refs.chart, {
      type: 'doughnut',
      data: this.buildChartData(),
      options: this.buildChartOptions()
    });
  },
  buildChartData: function() {
    return {
      labels: [
        "Present", "Absent", "Late"
      ],
      datasets: [
        {
          data: [
            this.props.chartData.present_statuses,
            this.props.chartData.absent_statuses,
            this.props.chartData.late_statuses,
          ],
          backgroundColor: [
            "#7ED321",
            "#D0021B",
            "#F5A623"
          ]
        }
      ]
    };
  },
  buildChartOptions: function() {
    return {
      legend: {
        display: false
      },
      cutoutPercentage: 65,
      tooltips: {
        enabled: false
      }
    };
  },
  totalDaysMarked: function() {
    return this.props.chartData.present_statuses
      + this.props.chartData.absent_statuses
      + this.props.chartData.late_statuses;
  },
  drawTitle: function() {
    var ctx = this.refs.chart.getContext('2d');
    ctx.font = '30px Arial';
    ctx.fillText("Test", 100, 100);
  }
})
