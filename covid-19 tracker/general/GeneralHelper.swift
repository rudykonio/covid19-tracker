//
//  GeneralHelper.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 04/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import Foundation
import UIKit
import Charts
class GeneralHelper{
    private init(){}
    static func toggleViews(countryDataVC:CountryDataViewController? = nil, mapVC:MapViewController? = nil){
        if let countryDataVC = countryDataVC {
            countryDataVC.activityIndicator.isHidden = true
            countryDataVC.tryAgainBtn.isHidden = false
        }
        if let mapVC = mapVC {
            mapVC.activityIndicator.isHidden = true
            mapVC.tryAgainBtn.isHidden = false
        }
    }
    
    static func configureGraph(cases:[String:Int],deceased:[String:Int],lineChartView:LineChartView){
        var casesArr = [Int]()
        var deceasedArr = [Int]()
        for (_,covidCase) in cases{
            casesArr.append(covidCase)
        }
        for (_,deceasedCase) in deceased{
            deceasedArr.append(deceasedCase)
        }
        casesArr = casesArr.sorted()
        deceasedArr = deceasedArr.sorted()
        var casesEntry = [ChartDataEntry]()
        var deceasedEntry = [ChartDataEntry]()
        var i:Int = 0
        var j:Int = 0
        for covidCase in casesArr{
            casesEntry.append(ChartDataEntry(x: Double(i), y: Double(covidCase)))
            i+=1
        }
        for deceasedCase in deceasedArr{
            deceasedEntry.append(ChartDataEntry(x: Double(j), y: Double(deceasedCase)))
            j+=1
        }
        let casesDataSet = LineChartDataSet(entries: casesEntry, label: "Cases")
        let deceasedDataSet = LineChartDataSet(entries: deceasedEntry, label: "Deceased")
        casesDataSet.mode = .linear
        deceasedDataSet.mode = .linear
        casesDataSet.drawCirclesEnabled = false
        deceasedDataSet.drawCirclesEnabled = false
        casesDataSet.drawFilledEnabled = true
        deceasedDataSet.drawFilledEnabled = true
        casesDataSet.fillColor = .systemOrange
        deceasedDataSet.fillColor = .systemRed
        casesDataSet.setColor(.systemOrange)
        deceasedDataSet.setColor(.systemRed)
        casesDataSet.drawValuesEnabled = false
        deceasedDataSet.drawValuesEnabled = false
        let lineChartData = LineChartData(dataSets: [casesDataSet,deceasedDataSet])
        lineChartView.data = lineChartData
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInCubic)
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.noDataText = "no data to display"
        lineChartView.backgroundColor = .systemGray6
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
    }
}
extension UIImageView {
    func load(url: URL,completionHandler:@escaping(Data)->Void) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        completionHandler((self?.image?.pngData()!)!)
                    }
                }
            }
        }
    }
}
