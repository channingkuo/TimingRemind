//
//  ModelController.swift
//  TimingRemind
//
//  Created by Channing Kuo on 2017/10/3.
//  Copyright © 2017年 Channing Kuo. All rights reserved.
//

import UIKit

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageStruct: [TimerData] = []

    override init() {
        super.init()
        // Create the data model.
        let tableData = SQliteRepository.getData(tableName: "TIMERREMIND")
        if tableData.count <= 0 {
            // 初始化一条默认数据
            pageStruct = [TimerData(title: "First", repeatDays: Repeat(daysLine: "[]"))]
        } else {
            for (_, item) in tableData.enumerated(){
                var timerData = TimerData(title: (item["title"] as? String)!, repeatDays: Repeat(daysLine: (item["repeatDays"] as? String)!))
                timerData.LeftTime = (item["leftTime"] as? Date)!
                timerData.RightTime = (item["rightTime"] as? Date)!
                
                pageStruct += [timerData]
            }
        }
    }

    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.pageStruct.count == 0) || (index >= self.pageStruct.count) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        dataViewController.timerData = self.pageStruct[index]
        return dataViewController
    }

    func indexOfViewController(_ viewController: DataViewController) -> Int {
        var pageIndex = -1
        for (index, item) in pageStruct.enumerated() {
            if item.id == viewController.timerData.id {
                pageIndex = index
                break;
            }
        }
        return pageIndex == -1 ? NSNotFound : pageIndex
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageStruct.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

}

