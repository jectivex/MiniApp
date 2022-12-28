/**
 * Module to extract and gather information necessary to produce the right reports and an overview page for test cases.
 * 
 * Note: the term "consolidation" is used, throughout this module, for the following situation. 
 * Some implementations may come in different variants:
 * the same name (typically designating the core engine) but a separate versions ("variants")
 * for different environments, typically iOS, Android, or Web.
 * Per W3C these are not considered to be independent implementations and, therefore,
 * they should be considered as one implementation as far as the
 * formal CR report is concerned. On the other hand, there is value to keep the various implementation results separated.
 * 
 * To keep this, the report generator (and the display of the results) "duplicates" the list of
 * implementations: one is the original (ie, with variants kept separated) and
 * one where the result of all the variants are "consolidated" into a unique implementation report.
 * The duplication of these data is then reflected in the way the reports are displayed.
 * 
 * @packageDocumentation
 */


import * as fs_old_school from "fs";
const fs = fs_old_school.promises;

import { TestData, ImplementationReport, ImplementationData, ImplementationTable, Implementer, ReportData, ReqType, Constants } from './types';

/** 
 * Name tells it all...
 * 
 * @internal 
 */
function string_comparison(a: string, b: string): number {
    if (a < b) return -1;
    else if (a > b) return 1;
    else return 0;
}


/**
 * Get JSONLD file location
 * @param dirname 
 * @returns fname
 */
export async function get_jsonld_file(dirname: string): Promise<string> {
    let metadata_jsonld: string;
    try {
        metadata_jsonld = await fs.readFile(`${dirname}/${Constants.METADATA_FILE}`, 'utf-8');
    } catch (error) {
        console.warn(`test.jsonld document could not be accessed in directory ${dirname}`);
        throw (`test.jsonld document could not be accessed in directory "${dirname}"`)
    }
    return `${Constants.METADATA_FILE}`
}


/**
 * Find and extract the OPF file, following the official MiniApp mechanism
 * 
 * @param dirname Directory name
 * @returns JSONLD content in an JSON string
 */
async function get_jsonld(dirname: string): Promise<string> {
    const fname: string = await get_jsonld_file(dirname);
    try {
        return await fs.readFile(`${dirname}/${fname}`,'utf-8');
    } catch (error) {
        throw (`OPF file could not be accessed in directory "${dirname}"`)
    }
}


/** 
 * See if a file name path refers to a real file
 * 
 * @internal 
 */
export function isDirectory(name: string): boolean {
    return fs_old_school.lstatSync(name).isDirectory();
}


/** 
 * See if a file name path refers to a real file
 * 
 * @internal 
 */
export function isFile(name: string): boolean {
    return fs_old_school.lstatSync(name).isFile();
}


/**
 * Lists of a directory content.
 * 
 * (Note: at this moment this returns all the file names. Depending on the final configuration some filters may have to be added.)
 * 
 * @param dir_name name of the directory
 * @param filter_name a function to filter the retrieved list (e.g., no directories)
 * @returns lists of files in the directory
 */
// eslint-disable-next-line @typescript-eslint/no-unused-vars
export async function get_list_dir(dir_name: string, filter_name: (name: string) => boolean = (name: string) => true): Promise<string[]> {
    // The filter works on the full path, hence this extra layer
    const file_name_filter = (name: string): boolean => {
        return name.startsWith('xx-') === false && filter_name(`${dir_name}/${name}`);
    }
    const file_names = await fs.readdir(dir_name);
    return file_names.filter(file_name_filter)
}


/**
 * Get all the implementation reports from the file system.
 * The results are sorted using the implementation's name as a key.
 * 
 * @param dir_name the directory that contains the implementation reports
 */
async function get_implementation_reports(dir_name: string): Promise<ImplementationReport[]> {
    // Filter out the "null" values from the implementation reports
    const remove_nulls = (inp: ImplementationReport): ImplementationReport => {
        const val: any = {};
        for (const key in inp.tests) {
            if (inp.tests[key] !== null) {
                val[key] = inp.tests[key]
            }
        }
        inp.tests = val;
        return inp;
    }

    // Get a single implementation report, which must be a JSON file
    const get_implementation_report = async (file_name: string): Promise<ImplementationReport> => {
        const implementation_report = await fs.readFile(file_name, 'utf-8');
        try {
            return remove_nulls(JSON.parse(implementation_report) as ImplementationReport);
        } catch (error) {
            console.warn(`Warning: unable to parse ${file_name}; ignored`);
            return undefined;
        }
    };

    const implementation_list = await get_list_dir(dir_name, isFile);

    // Use the 'Promise.all' trick to get to all the implementation reports in one async step rather than going through a cycle
    const report_list_promises: Promise<ImplementationReport>[] = implementation_list.map((file_name) => get_implementation_report(`${dir_name}/${file_name}`));
    const proto_implementation_reports: ImplementationReport[] = await Promise.all(report_list_promises);
    const implementation_reports: ImplementationReport[] = proto_implementation_reports.filter((entry) => entry !== undefined); 
    implementation_reports.sort((a,b) => string_comparison(a.name, b.name));

    return implementation_reports
}

/**
 * Create consolidated implementation reports.
 * 
 * Some implementation report appear several times as 'variants' (typically android, ios, or web). These
 * are usually using the same engine, so their results should be merged into one for the purpose of a formal
 * report for the AC.
 *
 * @param implementations the original list of implementation reports
 * @returns a consolidated list of the implementation reports
 */
function consolidate_implementation_reports(implementations: ImplementationReport[]): ImplementationReport[] {
    // Results of a test, indexed by the ID of the test itself
    interface TestResults { [index: string]: boolean }
    interface Variants { [index: string]: TestResults[]}
    const final: ImplementationReport[] = [];
    const to_be_consolidated: Variants = {};

    // This is the real meat: create a new set of test results combining the test result of the variants.
    // The problem is that different variants may skip some tests, i.e., the
    // final list of test names must be the union of all the tests in the different variants
    const consolidate_test_results = (variant_results: TestResults[]): TestResults => {
        const retval: TestResults = {};

        // Get all keys together
        const all_keys: string[] = variant_results
            .map((variant) => Object.keys(variant))
            .reduce( (p: string[], c: string[]): string[] => [...p, ...c], []);
        // This is a neat trick to remove duplicates!
        const keys: string[] = [...new Set(all_keys)];

        // Next is to merge all the results. The rule is to set the result to 'true' if at least one of the values is 'true'
        for (const key of keys) {
            // Minor side effect trick: for each key there is at least one Test Result that has a value. We can therefore
            // safely set the result to 'false' temporarily if the test result is not available; there must be a false or true
            // value somewhere else in the array anyway.
            const all_results: boolean[] = variant_results.map((results: TestResults): boolean => key in results ? results[key] : false);
            retval[key] = all_results.reduce( (p: boolean, c: boolean): boolean => p || c, false);
        }
        return retval;
    };

    // 1. Separate the reports with variants from the "plain" reports
    for (const impl of implementations) {
        if ('variant' in impl) {
            // Collect the variants with a common name
            if (!(impl.name in to_be_consolidated)) {
                to_be_consolidated[impl.name] = [];
            }
            to_be_consolidated[impl.name].push(impl.tests);
        } else {
            final.push(impl);
        }
    }
    // TODO: if there is a ref somewhere, then use that in the output as well

    // 2. consolidate the variants for the same name, and add those to the result
    for (const variant_name in to_be_consolidated) {
        const tests = consolidate_test_results(to_be_consolidated[variant_name]);
        final.push({
            name    : variant_name,
            variant : 'consolidated',
            tests,
        });
    }

    // Re-sort the array to follow the original order
    const retval: ImplementationReport[] = final.sort((a,b) => string_comparison(a.name, b.name));
    return retval;
}


/**
 * Extract all the test information from all available tests.
 * 
 * @param dir_name test directory name
 * @returns MiniApp metadata converted into the [[TestData]] structure
 */
// eslint-disable-next-line max-lines-per-function
async function get_test_metadata(dir_name: string): Promise<TestData[]> {
    // Extract the metadata information from the tests' package file for a single test
    const get_single_test_metadata = async (file_name: string): Promise<TestData> => {
        // Note the heavy use of "any" in the function; this is related to the fact that
        // the xmljs package returns a pretty "unpredictable" object...
        // As a consequence, this function bypasses most of TypeScript's checks. Alas!
        const get_string_value = (label: string, fallback: string, metadata: any): string => {
            try {
                const entry = metadata[label];
                if (entry === undefined) {
                    return fallback;
                } else {
                    const retval = typeof entry === "string" ? entry : entry._;
                    return retval.trim().replace(/\s+/g, ' ');
                }
            } catch {
                return fallback;
            }
        };

        const get_array_of_string_values = (label: string, fallback:string, metadata: any): string[] => {
            try {
                const entries = metadata[label];
                if (entries === undefined || entries.length === 0) {
                    return [fallback];
                } else {
                    return entries.map( (entry: any): string => {
                        const retval = typeof entry === "string" ? entry : entry._;
                        return retval.trim().replace(/\s+/g, ' ');
                    });
                }
            } catch {
                return [fallback]
            }
        };

        const get_array_of_meta_values = (property: string, metadata: any): string[] => {
            return metadata[property]
        }

        const get_single_meta_value = (property: string, metadata: any): any => {
            return metadata[property]
        }

        const get_required = (metadata: any): ReqType => {
            const is_set = get_single_meta_value("dcterms:conformsTo", metadata);
            if (is_set === undefined) {
                return "must";
            } else {
                const val: string = (<string>is_set).toLowerCase();
                switch (val) {
                case "must":
                case "should":
                case "may":
                    return val;
                default:
                    return "must";
                }
            }
        }

        const get_final_title = (metadata: any): string => {
            const alternate_title = get_single_meta_value("dcterms:alternative", metadata);
            return alternate_title === undefined ? get_string_value("dc:title", "(No title)", metadata) : alternate_title._;    
        }

        // ---------

        let metadata_json: object;
        try {
            metadata_json = JSON.parse(await get_jsonld(file_name))
        } catch (error) {
            console.warn(`${error}; skipped.`);
            return undefined;
        }

        return {
            identifier  : get_string_value("dc:identifier", file_name.split('/').pop(), metadata_json),
            title       : get_final_title(metadata_json),
            description : get_string_value("dc:description", "(No description)", metadata_json),
            coverage    : get_string_value("dc:coverage", "(Uncategorized)", metadata_json),
            creators    : get_array_of_string_values("dc:creator", "(Unknown)", metadata_json),
            required    : get_required(metadata_json),
            references  : get_array_of_meta_values("dcterms:isReferencedBy", metadata_json),
        }
    }

    // Get the test descriptions
    const test_list = await get_list_dir(dir_name, isDirectory);
    const test_data_promises: Promise<TestData>[] = test_list.map((name: string) => get_single_test_metadata(`${dir_name}/${name}`));
    
    // Use the 'Promise.all' trick to get to all the data in one async step rather than going through a cycle
    const test_data: TestData[] = await Promise.all(test_data_promises);
    return test_data.filter((entry) => entry !== undefined);
}


/**
 * Combine the metadata, as retrieved from the tests, and the implementation reports into 
 * one structure for each tests with the test run results included
 * 
 */
function create_implementation_data(metadata: TestData[], implementations: ImplementationReport[]): ImplementationData[] {
    return metadata.map((single_test: TestData): ImplementationData => {
        // Extend the object with, at first, an empty array of implementations
        const retval: ImplementationData = {...single_test, implementations: []};
        retval.implementations = implementations.map((implementor: ImplementationReport) => {
            if (single_test.identifier in implementor.tests) {
                return implementor.tests[single_test.identifier]
            } else {
                return undefined
            }
        });
        return retval;
    })
}


/**
 * Create Implementation tables: a separate list of implementations for each "section", ie, a collection of tests
 * that share the same `dc:coverage` data
 * 
 */
function create_implementation_tables(implementation_data: ImplementationData[]): ImplementationTable[] {
    const retval: ImplementationTable[] = [];

    for (const impl_data of implementation_data) {
        const header = impl_data.coverage;
        let section = retval.find((table) => table.header === header);
        if (section === undefined) {
            section = {
                header          : header,
                implementations : [impl_data],
            }
            retval.push(section)
        } else {
            section.implementations.push(impl_data)
        }
    }

    // Sort the results per section heading
    // Note that this sounds like unnecessary, because, at a later step, the sections are reordered
    // per the configuration file. But this is a safety measure: if the configuration file is
    // not available and/or erroneous, the order is still somewhat deterministic.
    retval.sort((a,b) => string_comparison(a.header, b.header));
    return retval;
}


/* ------------------------------------------------------------------------------------------------------ */
/*                                   External entry points                                                */
/* ------------------------------------------------------------------------------------------------------ */

/**
 * Get all the test reports and tests files metadata and create the data structures that allow a simple
 * generation of a final report
 * 
 * @param tests directory where the tests reside
 * @param reports directory where the implementation reports reside
 */
export async function get_report_data(tests: string, reports: string): Promise<ReportData> {
    const sort_test_data = (all_tests: TestData[]): TestData[] => {
        const required_tests: TestData[] = [];
        const optional_tests: TestData[] = [];
        const possible_tests: TestData[] = [];

        const get_array = (val: ReqType): TestData[] => {
            switch (val) {
            case "must": return required_tests;
            case "should": return optional_tests;
            case "may": return possible_tests;
            // This is, in fact, not necessary, but typescript is not sophisticated enough to see that...
            // and I hate eslint warnings!
            default: return required_tests;
            }
        }

        for (const test of all_tests) {
            get_array(test.required).push(test);
        }

        // This is, most of the times, unnecessary, because the directory reading has an alphabetic order already.
        // However, in rare cases, the test's file name and the test's identifier may not coincide, and the latter
        // should prevail...
        return [
            ...required_tests.sort((a,b) => string_comparison(a.identifier, b.identifier)),
            ...optional_tests.sort((a,b) => string_comparison(a.identifier, b.identifier)),
            ...possible_tests.sort((a,b) => string_comparison(a.identifier, b.identifier)),
        ]
    }

    // Get the metadata for all available tests;
    const metadata: TestData[] = sort_test_data(await get_test_metadata(tests));

    // Get the list of available implementation reports
    const impl_list: ImplementationReport[] = await get_implementation_reports(reports);
    const consolidated_list: ImplementationReport[] = consolidate_implementation_reports(impl_list);

    // Combine the two lists to create an array of Implementation data
    const implementation_data: ImplementationData[] = create_implementation_data(metadata, impl_list);
    const consolidated_data: ImplementationData[] = create_implementation_data(metadata, consolidated_list)

    // Section the list of implementation data
    const tables: ImplementationTable[] = create_implementation_tables(implementation_data)
    const consolidated_tables: ImplementationTable[] = create_implementation_tables(consolidated_data)

    // Create an array of implementers that only contain the bare minimum
    const implementers = impl_list as Implementer[];
    const consolidated_implementers = consolidated_list as Implementer[];

    return {tables, consolidated_tables, implementers, consolidated_implementers}
}

/**
 * Get a list of the tests file names, to be used to generate a template report.
 * 
 * @param report the full report, as generated by earlier calls
 */
export function get_template(report: ReportData): ImplementationReport {
    const test_list: {[index: string]: boolean } = {};
    const keys: string[] = [];

    // Get the keys first in order to sort them
    for (const table of report.tables) {
        for (const impl of table.implementations) {
            keys.push(impl.identifier);
        }
    }
    for (const key of keys.sort()) {
        test_list[key] = null;
    }

    return {
        "name"  : "(Implementation's name)",
        "ref"   : "https://www.example.com",
        "tests" : test_list,
    }
}
