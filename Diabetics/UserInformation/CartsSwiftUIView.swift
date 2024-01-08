import SwiftUI
import Charts

struct CartsSwiftUIView: View {
    let dataMeasure: [DataModel.Measurement]
    init(dataMeasure: [DataModel.Measurement]) {
        self.dataMeasure = dataMeasure.sorted(by: { x1, x2 in
            if x1.date < x2.date {
                return true
            } else {
                return false
            }
        })
    }
    @State var range: (Date, Date)? = nil

    var rangedDataMeasure: [DataModel.Measurement] {
        return dataMeasure.filter { measurement in
            guard let range = range  else { return false }
            if range.0 <= measurement.date && measurement.date <= range.1 {
                return true
            }
            if range.1 <= measurement.date && measurement.date <= range.0 {
                return true
            } else {
                return false
            }
        }
    }

    func makeMeasureInfoString(array: [DataModel.Measurement]) -> [String] {
        let stringArray = array.map { element in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yy HH:mm"
            let stringDate = dateFormatter.string(from: element.date)
            
            let stringValue = "\(element.value)"
            return stringDate + " " + stringValue
        }
        return stringArray
    }

    var rangeArray: [String] {
        return makeMeasureInfoString(array: rangedDataMeasure)
    }

    var body: some View {
        ZStack {
            Color(.gray).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Analytics").font(.system(size: 32)).fontWeight(.heavy).padding(20)
                ZStack {
                    Color.white
                    Chart {
                        ForEach(dataMeasure, id: \.self) { measureInfo in
                            let date = measureInfo.date
                            let value = Double(measureInfo.value)
                            AreaMark(
                                x: .value("Date Of measure", date, unit: .day),
                                yStart: .value("Min measure", 3.3),
                                yEnd: .value("Max measure", 7.8)
                            )
                            .opacity(0.5)
                            .foregroundStyle(.gray)
                            LineMark(
                                x: .value("Date Of measure", date, unit: .day),
                                y: .value("Value", value)
                            )
                            .foregroundStyle(.red)
                            .interpolationMethod(.catmullRom)
                            .symbol(.circle)
                        }
                        if let range = range {
                            RectangleMark(
                                xStart: .value("Range Start", range.0),
                                xEnd: .value("Range End", range.1)
                            )
                            .foregroundStyle(.blue.opacity(0.2))
                        }
                    }
                    .padding(.all, 20)
                    .chartYScale(domain: 0.0 ... 10.0)
                    .chartForegroundStyleScale(["Measure": .red])
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartPlotStyle { plotArea in
                        plotArea.background(.gray.opacity(0.2))
                    }
                    .chartOverlay { proxy in
                        GeometryReader { g in
                            Rectangle().fill(.clear).contentShape(Rectangle())
                                .gesture(DragGesture()
                                    .onChanged{ value in
                                        let startX = value.startLocation.x - g[proxy.plotAreaFrame].origin.x
                                        let currentX = value.location.x - g[proxy.plotAreaFrame].origin.x
                                        if let startDate: Date = proxy.value(atX: startX),
                                           let currentDate: Date = proxy.value(atX: currentX) {
                                            range = (startDate, currentDate)
                                        }
                                    }
                                    .onEnded { _ in range = nil }
                                )
                        }
                    }
                }.frame(height: 350)
                List(rangeArray, id: \.self) { element in
                    Text(element)
                }
            }
        }
    }
}

